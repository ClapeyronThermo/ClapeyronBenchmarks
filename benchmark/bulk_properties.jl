function add_pure_bulk_benchmarks!(Suite::BenchmarkGroup, model_name, model, p, z, fluid_label)
    Tsat = guard_benchmark(benchmark_path("volume", "liquid-phase", model_name, fluid_label)) do
        saturation_temperature(model, p)[1]
    end
    isnothing(Tsat) && return nothing
    T_liquid = Tsat - 10
    T_vapour = Tsat + 10

    register_benchmark!(Suite["volume"]["liquid-phase"], model_name, fluid_label,
        benchmark_path("volume", "liquid-phase", model_name, fluid_label),
        () -> volume(model, p, T_liquid, z; phase=:l),
        () -> @benchmarkable volume($model, $p, $T_liquid, $z; phase=:l))

    register_benchmark!(Suite["volume"]["vapour-phase"], model_name, fluid_label,
        benchmark_path("volume", "vapour-phase", model_name, fluid_label),
        () -> volume(model, p, T_vapour, z; phase=:v),
        () -> @benchmarkable volume($model, $p, $T_vapour, $z; phase=:v))

    register_benchmark!(Suite["enthalpy"]["liquid-phase"], model_name, fluid_label,
        benchmark_path("enthalpy", "liquid-phase", model_name, fluid_label),
        () -> enthalpy(model, p, T_liquid, z; phase=:l),
        () -> @benchmarkable enthalpy($model, $p, $T_liquid, $z; phase=:l))

    register_benchmark!(Suite["enthalpy"]["vapour-phase"], model_name, fluid_label,
        benchmark_path("enthalpy", "vapour-phase", model_name, fluid_label),
        () -> enthalpy(model, p, T_vapour, z; phase=:v),
        () -> @benchmarkable enthalpy($model, $p, $T_vapour, $z; phase=:v))

    register_benchmark!(Suite["speed_of_sound"]["liquid-phase"], model_name, fluid_label,
        benchmark_path("speed_of_sound", "liquid-phase", model_name, fluid_label),
        () -> speed_of_sound(model, p, T_liquid, z; phase=:l),
        () -> @benchmarkable speed_of_sound($model, $p, $T_liquid, $z; phase=:l))

    register_benchmark!(Suite["speed_of_sound"]["vapour-phase"], model_name, fluid_label,
        benchmark_path("speed_of_sound", "vapour-phase", model_name, fluid_label),
        () -> speed_of_sound(model, p, T_vapour, z; phase=:v),
        () -> @benchmarkable speed_of_sound($model, $p, $T_vapour, $z; phase=:v))
    nothing
end

function add_gas_bulk_benchmarks!(Suite::BenchmarkGroup, model_name, model, p, T, z, fluid_label)
    register_benchmark!(Suite["volume"]["vapour-phase"], model_name, fluid_label,
        benchmark_path("volume", "vapour-phase", model_name, fluid_label),
        () -> volume(model, p, T, z; phase=:v),
        () -> @benchmarkable volume($model, $p, $T, $z; phase=:v))

    register_benchmark!(Suite["speed_of_sound"]["vapour-phase"], model_name, fluid_label,
        benchmark_path("speed_of_sound", "vapour-phase", model_name, fluid_label),
        () -> speed_of_sound(model, p, T, z; phase=:v),
        () -> @benchmarkable speed_of_sound($model, $p, $T, $z; phase=:v))

    register_benchmark!(Suite["joule_thomson_coefficient"]["vapour-phase"], model_name, fluid_label,
        benchmark_path("joule_thomson_coefficient", "vapour-phase", model_name, fluid_label),
        () -> joule_thomson_coefficient(model, p, T, z; phase=:v),
        () -> @benchmarkable joule_thomson_coefficient($model, $p, $T, $z; phase=:v))
    nothing
end

function add_common_bulk_benchmarks!(Suite::BenchmarkGroup, models, p, z, fluid_label)
    for (model_name, model) in models
        Tb = guard_benchmark(benchmark_path("volume", "liquid-phase", model_name, fluid_label)) do
            bubble_temperature(model, p, z)[1]
        end
        Td = guard_benchmark(benchmark_path("volume", "vapour-phase", model_name, fluid_label)) do
            dew_temperature(model, p, z)[1]
        end

        if !isnothing(Tb) && !isnothing(Td)
            T_liquid = Tb - 10
            T_vapour = Td + 10

            register_benchmark!(Suite["volume"]["liquid-phase"], model_name, fluid_label,
                benchmark_path("volume", "liquid-phase", model_name, fluid_label),
                () -> volume(model, p, T_liquid, z; phase=:l),
                () -> @benchmarkable volume($model, $p, $T_liquid, $z; phase=:l))

            register_benchmark!(Suite["volume"]["vapour-phase"], model_name, fluid_label,
                benchmark_path("volume", "vapour-phase", model_name, fluid_label),
                () -> volume(model, p, T_vapour, z; phase=:v),
                () -> @benchmarkable volume($model, $p, $T_vapour, $z; phase=:v))

            register_benchmark!(Suite["enthalpy"]["liquid-phase"], model_name, fluid_label,
                benchmark_path("enthalpy", "liquid-phase", model_name, fluid_label),
                () -> enthalpy(model, p, T_liquid, z; phase=:l),
                () -> @benchmarkable enthalpy($model, $p, $T_liquid, $z; phase=:l))

            register_benchmark!(Suite["enthalpy"]["vapour-phase"], model_name, fluid_label,
                benchmark_path("enthalpy", "vapour-phase", model_name, fluid_label),
                () -> enthalpy(model, p, T_vapour, z; phase=:v),
                () -> @benchmarkable enthalpy($model, $p, $T_vapour, $z; phase=:v))

            register_benchmark!(Suite["isobaric_heat_capacity"]["liquid-phase"], model_name, fluid_label,
                benchmark_path("isobaric_heat_capacity", "liquid-phase", model_name, fluid_label),
                () -> isobaric_heat_capacity(model, p, T_liquid, z; phase=:l),
                () -> @benchmarkable isobaric_heat_capacity($model, $p, $T_liquid, $z; phase=:l))

            register_benchmark!(Suite["isobaric_heat_capacity"]["vapour-phase"], model_name, fluid_label,
                benchmark_path("isobaric_heat_capacity", "vapour-phase", model_name, fluid_label),
                () -> isobaric_heat_capacity(model, p, T_vapour, z; phase=:v),
                () -> @benchmarkable isobaric_heat_capacity($model, $p, $T_vapour, $z; phase=:v))
        end
    end
    nothing
end

function add_ph_benchmarks!(Suite::BenchmarkGroup, models, p, z, fluid_label)
    for (model_name, model) in models
        Tb = guard_benchmark(benchmark_path("PH.temperature", "two-phase", model_name, fluid_label)) do
            bubble_temperature(model, p, z)[1]
        end
        Td = guard_benchmark(benchmark_path("PH.temperature", "vapour-phase", model_name, fluid_label)) do
            dew_temperature(model, p, z)[1]
        end

        if !isnothing(Tb) && !isnothing(Td)
            hb = guard_benchmark(benchmark_path("PH.entropy", "two-phase", model_name, fluid_label)) do
                enthalpy(model, p, Tb, z; phase=:l)
            end
            hd = guard_benchmark(benchmark_path("PH.entropy", "two-phase", model_name, fluid_label)) do
                enthalpy(model, p, Td, z; phase=:v)
            end

            if !isnothing(hb) && !isnothing(hd)
                h_two_phase = (hb + hd) / 2
                T_liquid = Tb - 10
                T_vapour = Td + 10
                h_liquid = guard_benchmark(benchmark_path("PH.temperature", "liquid-phase", model_name, fluid_label)) do
                    enthalpy(model, p, T_liquid, z; phase=:l)
                end
                h_vapour = guard_benchmark(benchmark_path("PH.temperature", "vapour-phase", model_name, fluid_label)) do
                    enthalpy(model, p, T_vapour, z; phase=:v)
                end

                if !isnothing(h_liquid) && !isnothing(h_vapour)
                    register_benchmark!(Suite["PH.temperature"]["two-phase"], model_name, fluid_label,
                        benchmark_path("PH.temperature", "two-phase", model_name, fluid_label),
                        () -> Clapeyron.PH.temperature(model, p, h_two_phase, z),
                        () -> @benchmarkable Clapeyron.PH.temperature($model, $p, $h_two_phase, $z))

                    register_benchmark!(Suite["PH.temperature"]["liquid-phase"], model_name, fluid_label,
                        benchmark_path("PH.temperature", "liquid-phase", model_name, fluid_label),
                        () -> Clapeyron.PH.temperature(model, p, h_liquid, z),
                        () -> @benchmarkable Clapeyron.PH.temperature($model, $p, $h_liquid, $z))

                    register_benchmark!(Suite["PH.temperature"]["vapour-phase"], model_name, fluid_label,
                        benchmark_path("PH.temperature", "vapour-phase", model_name, fluid_label),
                        () -> Clapeyron.PH.temperature(model, p, h_vapour, z),
                        () -> @benchmarkable Clapeyron.PH.temperature($model, $p, $h_vapour, $z))

                    register_benchmark!(Suite["PH.entropy"]["two-phase"], model_name, fluid_label,
                        benchmark_path("PH.entropy", "two-phase", model_name, fluid_label),
                        () -> Clapeyron.PH.entropy(model, p, h_two_phase, z),
                        () -> @benchmarkable Clapeyron.PH.entropy($model, $p, $h_two_phase, $z))

                    register_benchmark!(Suite["PH.entropy"]["liquid-phase"], model_name, fluid_label,
                        benchmark_path("PH.entropy", "liquid-phase", model_name, fluid_label),
                        () -> Clapeyron.PH.entropy(model, p, h_liquid, z),
                        () -> @benchmarkable Clapeyron.PH.entropy($model, $p, $h_liquid, $z))

                    register_benchmark!(Suite["PH.entropy"]["vapour-phase"], model_name, fluid_label,
                        benchmark_path("PH.entropy", "vapour-phase", model_name, fluid_label),
                        () -> Clapeyron.PH.entropy(model, p, h_vapour, z),
                        () -> @benchmarkable Clapeyron.PH.entropy($model, $p, $h_vapour, $z))
                end
            end
        end
    end
    nothing
end

function add_pure_ph_benchmarks!(Suite::BenchmarkGroup, model_name, model, p, z, fluid_label)
    Tsat = guard_benchmark(benchmark_path("PH.temperature", "two-phase", model_name, fluid_label)) do
        saturation_temperature(model, p)[1]
    end
    isnothing(Tsat) && return nothing

    hb = guard_benchmark(benchmark_path("PH.entropy", "two-phase", model_name, fluid_label)) do
        enthalpy(model, p, Tsat, z; phase=:l)
    end
    hd = guard_benchmark(benchmark_path("PH.entropy", "two-phase", model_name, fluid_label)) do
        enthalpy(model, p, Tsat, z; phase=:v)
    end
    (isnothing(hb) || isnothing(hd)) && return nothing
    h_two_phase = (hb + hd) / 2

    T_liquid = Tsat - 10
    T_vapour = Tsat + 10
    h_liquid = guard_benchmark(benchmark_path("PH.temperature", "liquid-phase", model_name, fluid_label)) do
        enthalpy(model, p, T_liquid, z; phase=:l)
    end
    h_vapour = guard_benchmark(benchmark_path("PH.temperature", "vapour-phase", model_name, fluid_label)) do
        enthalpy(model, p, T_vapour, z; phase=:v)
    end
    (isnothing(h_liquid) || isnothing(h_vapour)) && return nothing

    register_benchmark!(Suite["PH.temperature"]["two-phase"], model_name, fluid_label,
        benchmark_path("PH.temperature", "two-phase", model_name, fluid_label),
        () -> Clapeyron.PH.temperature(model, p, h_two_phase, z),
        () -> @benchmarkable Clapeyron.PH.temperature($model, $p, $h_two_phase, $z))

    register_benchmark!(Suite["PH.temperature"]["liquid-phase"], model_name, fluid_label,
        benchmark_path("PH.temperature", "liquid-phase", model_name, fluid_label),
        () -> Clapeyron.PH.temperature(model, p, h_liquid, z),
        () -> @benchmarkable Clapeyron.PH.temperature($model, $p, $h_liquid, $z))

    register_benchmark!(Suite["PH.temperature"]["vapour-phase"], model_name, fluid_label,
        benchmark_path("PH.temperature", "vapour-phase", model_name, fluid_label),
        () -> Clapeyron.PH.temperature(model, p, h_vapour, z),
        () -> @benchmarkable Clapeyron.PH.temperature($model, $p, $h_vapour, $z))

    register_benchmark!(Suite["PH.entropy"]["two-phase"], model_name, fluid_label,
        benchmark_path("PH.entropy", "two-phase", model_name, fluid_label),
        () -> Clapeyron.PH.entropy(model, p, h_two_phase, z),
        () -> @benchmarkable Clapeyron.PH.entropy($model, $p, $h_two_phase, $z))

    register_benchmark!(Suite["PH.entropy"]["liquid-phase"], model_name, fluid_label,
        benchmark_path("PH.entropy", "liquid-phase", model_name, fluid_label),
        () -> Clapeyron.PH.entropy(model, p, h_liquid, z),
        () -> @benchmarkable Clapeyron.PH.entropy($model, $p, $h_liquid, $z))

    register_benchmark!(Suite["PH.entropy"]["vapour-phase"], model_name, fluid_label,
        benchmark_path("PH.entropy", "vapour-phase", model_name, fluid_label),
        () -> Clapeyron.PH.entropy(model, p, h_vapour, z),
        () -> @benchmarkable Clapeyron.PH.entropy($model, $p, $h_vapour, $z))
    nothing
end
