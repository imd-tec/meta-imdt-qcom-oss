// Runs a real model repeatedly on the cDSP's HTP (NPU) backend via
// onnxruntime-qnn for a fixed duration, to catch anything that only shows up
// under sustained use (a one-shot inference can succeed on a session that
// wedges shortly after). Model I/O is introspected at runtime rather than
// hardcoded, so this works against any single-input, single-output model.
#include "onnxruntime_cxx_api.h"

#include <chrono>
#include <cstdint>
#include <cstdio>
#include <string>
#include <unordered_map>
#include <vector>

int main(int argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: %s <model.onnx> [duration_seconds]\n", argv[0]);
        return 1;
    }
    const char* model_path = argv[1];

    try {
        int duration_s = 30;
        if (argc > 2) {
            const std::string duration_arg(argv[2]);
            size_t parsed = 0;
            duration_s = std::stoi(duration_arg, &parsed);
            if (parsed != duration_arg.size() || duration_s <= 0) {
                fprintf(stderr, "duration_seconds must be a positive integer\n");
                return 1;
            }
        }
        Ort::Env env(ORT_LOGGING_LEVEL_WARNING, "cdsp-htp-test");

        Ort::SessionOptions so;
        so.AddConfigEntry("session.disable_cpu_ep_fallback", "1");

        std::unordered_map<std::string, std::string> qnn_options;
        qnn_options["backend_path"] = "libQnnHtp.so";
        qnn_options["qnn_context_priority"] = "low";

        const char* registration_name = "QNNExecutionProvider";
        env.RegisterExecutionProviderLibrary(registration_name, ORT_TSTR("libonnxruntime_providers_qnn.so"));

        std::vector<Ort::ConstEpDevice> ep_devices = env.GetEpDevices();
        const OrtEpDevice* target = nullptr;
        for (auto& d : ep_devices) {
            if (std::string(d.EpName()) == registration_name) target = d;
        }
        if (!target) {
            fprintf(stderr, "RESULT: FAIL - no EP device registered under name %s\n", registration_name);
            return 4;
        }
        so.AppendExecutionProvider_V2(env, {Ort::ConstEpDevice(target)}, qnn_options);

        printf("Loading model: %s\n", model_path);
        Ort::Session session(env, model_path, so);

        size_t n_in = session.GetInputCount();
        size_t n_out = session.GetOutputCount();
        printf("Session created. inputs=%zu outputs=%zu\n", n_in, n_out);

        Ort::AllocatorWithDefaultOptions allocator;

        std::vector<Ort::AllocatedStringPtr> input_name_holders;
        std::vector<const char*> input_names;
        std::vector<Ort::Value> input_tensors;
        std::vector<std::vector<float>> input_buffers;

        for (size_t i = 0; i < n_in; i++) {
            auto name_ptr = session.GetInputNameAllocated(i, allocator);
            input_names.push_back(name_ptr.get());
            input_name_holders.push_back(std::move(name_ptr));

            Ort::TypeInfo type_info = session.GetInputTypeInfo(i);
            auto tensor_info = type_info.GetTensorTypeAndShapeInfo();
            std::vector<int64_t> shape = tensor_info.GetShape();
            for (auto& d : shape) if (d < 0) d = 1;

            int64_t count = 1;
            for (auto d : shape) count *= d;

            input_buffers.emplace_back(static_cast<size_t>(count), 0.0f);
            Ort::MemoryInfo mem_info = Ort::MemoryInfo::CreateCpu(OrtArenaAllocator, OrtMemTypeDefault);
            input_tensors.push_back(Ort::Value::CreateTensor<float>(
                mem_info, input_buffers.back().data(), input_buffers.back().size(),
                shape.data(), shape.size()));
        }

        std::vector<Ort::AllocatedStringPtr> output_name_holders;
        std::vector<const char*> output_names;
        for (size_t i = 0; i < n_out; i++) {
            auto name_ptr = session.GetOutputNameAllocated(i, allocator);
            output_names.push_back(name_ptr.get());
            output_name_holders.push_back(std::move(name_ptr));
        }

        printf("Running inference on QNN HTP backend (cdsp) for %ds...\n", duration_s);
        auto deadline = std::chrono::steady_clock::now() + std::chrono::seconds(duration_s);
        long iterations = 0;
        double total_ms = 0.0;

        while (std::chrono::steady_clock::now() < deadline) {
            auto t0 = std::chrono::steady_clock::now();
            auto outputs = session.Run(Ort::RunOptions{nullptr},
                                        input_names.data(), input_tensors.data(), input_tensors.size(),
                                        output_names.data(), output_names.size());
            auto t1 = std::chrono::steady_clock::now();
            total_ms += std::chrono::duration<double, std::milli>(t1 - t0).count();
            iterations++;

            if (iterations == 1) {
                auto shape = outputs[0].GetTensorTypeAndShapeInfo().GetShape();
                printf("Output[0] shape:");
                for (auto d : shape) printf(" %lld", (long long)d);
                printf("\n");
            }
        }

        printf("Completed %ld inferences in %ds (avg %.2fms/inference)\n",
               iterations, duration_s, iterations ? total_ms / iterations : 0.0);
        printf("RESULT: PASS\n");
        return 0;
    } catch (const Ort::Exception& e) {
        fprintf(stderr, "RESULT: FAIL (Ort::Exception): %s\n", e.what());
        return 2;
    } catch (const std::exception& e) {
        fprintf(stderr, "RESULT: FAIL (exception): %s\n", e.what());
        return 3;
    }
}
