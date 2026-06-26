function add_pure_saturation_benchmarks!(Suite::BenchmarkGroup, model_name, model, p, fluid_label)
    Tsat = saturation_temperature(model, p)[1]

    register_benchmark!(Suite["saturation_temperature"]["default"], model_name, fluid_label,
        benchmark_path("saturation_temperature", "default", model_name, fluid_label),
        () -> saturation_temperature(model, p),
        () -> @benchmarkable saturation_temperature($model, $p))

    register_benchmark!(Suite["saturation_pressure"]["default"], model_name, fluid_label,
        benchmark_path("saturation_pressure", "default", model_name, fluid_label),
        () -> saturation_pressure(model, Tsat),
        () -> @benchmarkable saturation_pressure($model, $Tsat))
    nothing
end
