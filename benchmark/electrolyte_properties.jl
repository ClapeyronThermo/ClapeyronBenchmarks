function add_electrolyte_benchmarks!(Suite::BenchmarkGroup, model_name, model, p, T, z, m, fluid_label)
    register_benchmark!(Suite["volume"]["liquid-phase"], model_name, fluid_label,
        benchmark_path("volume", "liquid-phase", model_name, fluid_label),
        () -> volume(model, p, T, z; phase=:l),
        () -> @benchmarkable volume($model, $p, $T, $z; phase=:l))

    register_benchmark!(Suite["mean_ionic_activity_coefficient"]["default"], model_name, fluid_label,
        benchmark_path("mean_ionic_activity_coefficient", "default", model_name, fluid_label),
        () -> mean_ionic_activity_coefficient(model, p, T, m),
        () -> @benchmarkable mean_ionic_activity_coefficient($model, $p, $T, $m))

    register_benchmark!(Suite["osmotic_coefficient"]["default"], model_name, fluid_label,
        benchmark_path("osmotic_coefficient", "default", model_name, fluid_label),
        () -> osmotic_coefficient(model, p, T, m),
        () -> @benchmarkable osmotic_coefficient($model, $p, $T, $m))

    register_benchmark!(Suite["osmotic_coefficient_sat"]["default"], model_name, fluid_label,
        benchmark_path("osmotic_coefficient_sat", "default", model_name, fluid_label),
        () -> osmotic_coefficient_sat(model, T, m),
        () -> @benchmarkable osmotic_coefficient_sat($model, $T, $m))
    nothing
end
