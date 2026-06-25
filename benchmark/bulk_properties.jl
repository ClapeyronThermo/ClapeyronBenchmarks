function add_pure_bulk_benchmarks!(Suite::BenchmarkGroup, model_name, model, p, z, fluid_label)
    Tsat = saturation_temperature(model, p)[1]
    T_liquid = Tsat - 10
    T_vapour = Tsat + 10

    Suite["volume"]["liquid-phase"][model_name] = BenchmarkGroup()
    Suite["volume"]["liquid-phase"][model_name][fluid_label] = @benchmarkable volume($model, $p, $T_liquid, $z; phase=:l)

    Suite["volume"]["vapour-phase"][model_name] = BenchmarkGroup()
    Suite["volume"]["vapour-phase"][model_name][fluid_label] = @benchmarkable volume($model, $p, $T_vapour, $z; phase=:v)

    Suite["enthalpy"]["liquid-phase"][model_name] = BenchmarkGroup()
    Suite["enthalpy"]["liquid-phase"][model_name][fluid_label] = @benchmarkable enthalpy($model, $p, $T_liquid, $z; phase=:l)

    Suite["enthalpy"]["vapour-phase"][model_name] = BenchmarkGroup()
    Suite["enthalpy"]["vapour-phase"][model_name][fluid_label] = @benchmarkable enthalpy($model, $p, $T_vapour, $z; phase=:v)

    Suite["speed_of_sound"]["liquid-phase"][model_name] = BenchmarkGroup()
    Suite["speed_of_sound"]["liquid-phase"][model_name][fluid_label] = @benchmarkable speed_of_sound($model, $p, $T_liquid, $z; phase=:l)

    Suite["speed_of_sound"]["vapour-phase"][model_name] = BenchmarkGroup()
    Suite["speed_of_sound"]["vapour-phase"][model_name][fluid_label] = @benchmarkable speed_of_sound($model, $p, $T_vapour, $z; phase=:v)
    nothing
end

function add_gas_bulk_benchmarks!(Suite::BenchmarkGroup, model_name, model, p, T, z, fluid_label)
    Suite["volume"]["vapour-phase"][model_name] = BenchmarkGroup()
    Suite["volume"]["vapour-phase"][model_name][fluid_label] = @benchmarkable volume($model, $p, $T, $z; phase=:v)

    Suite["speed_of_sound"]["vapour-phase"][model_name] = BenchmarkGroup()
    Suite["speed_of_sound"]["vapour-phase"][model_name][fluid_label] = @benchmarkable speed_of_sound($model, $p, $T, $z; phase=:v)

    Suite["joule_thomson_coefficient"]["vapour-phase"][model_name] = BenchmarkGroup()
    Suite["joule_thomson_coefficient"]["vapour-phase"][model_name][fluid_label] = @benchmarkable joule_thomson_coefficient($model, $p, $T, $z; phase=:v)
    nothing
end

function add_common_bulk_benchmarks!(Suite::BenchmarkGroup, models, p, z, fluid_label)
    for (model_name, model) in models
        Tb = bubble_temperature(model, p, z)[1]
        Td = dew_temperature(model, p, z)[1]
        T_liquid = Tb - 10
        T_vapour = Td + 10

        Suite["volume"]["liquid-phase"][model_name] = BenchmarkGroup()
        Suite["volume"]["liquid-phase"][model_name][fluid_label] = @benchmarkable volume($model, $p, $T_liquid, $z; phase=:l)

        Suite["volume"]["vapour-phase"][model_name] = BenchmarkGroup()
        Suite["volume"]["vapour-phase"][model_name][fluid_label] = @benchmarkable volume($model, $p, $T_vapour, $z; phase=:v)

        Suite["enthalpy"]["liquid-phase"][model_name] = BenchmarkGroup()
        Suite["enthalpy"]["liquid-phase"][model_name][fluid_label] = @benchmarkable enthalpy($model, $p, $T_liquid, $z; phase=:l)

        Suite["enthalpy"]["vapour-phase"][model_name] = BenchmarkGroup()
        Suite["enthalpy"]["vapour-phase"][model_name][fluid_label] = @benchmarkable enthalpy($model, $p, $T_vapour, $z; phase=:v)

        Suite["isobaric_heat_capacity"]["liquid-phase"][model_name] = BenchmarkGroup()
        Suite["isobaric_heat_capacity"]["liquid-phase"][model_name][fluid_label] = @benchmarkable isobaric_heat_capacity($model, $p, $T_liquid, $z; phase=:l)

        Suite["isobaric_heat_capacity"]["vapour-phase"][model_name] = BenchmarkGroup()
        Suite["isobaric_heat_capacity"]["vapour-phase"][model_name][fluid_label] = @benchmarkable isobaric_heat_capacity($model, $p, $T_vapour, $z; phase=:v)
    end
    nothing
end

function add_ph_benchmarks!(Suite::BenchmarkGroup, models, p, z, fluid_label)
    for (model_name, model) in models
        Tb = bubble_temperature(model, p, z)[1]
        Td = dew_temperature(model, p, z)[1]

        hb = enthalpy(model, p, Tb, z; phase=:l)
        hd = enthalpy(model, p, Td, z; phase=:v)
        h_two_phase = (hb + hd) / 2

        T_liquid = Tb - 10
        T_vapour = Td + 10
        h_liquid = enthalpy(model, p, T_liquid, z; phase=:l)
        h_vapour = enthalpy(model, p, T_vapour, z; phase=:v)

        Suite["PH.temperature"]["two-phase"][model_name] = BenchmarkGroup()
        Suite["PH.temperature"]["two-phase"][model_name][fluid_label] = @benchmarkable Clapeyron.PH.temperature($model, $p, $h_two_phase, $z)

        Suite["PH.temperature"]["liquid-phase"][model_name] = BenchmarkGroup()
        Suite["PH.temperature"]["liquid-phase"][model_name][fluid_label] = @benchmarkable Clapeyron.PH.temperature($model, $p, $h_liquid, $z)

        Suite["PH.temperature"]["vapour-phase"][model_name] = BenchmarkGroup()
        Suite["PH.temperature"]["vapour-phase"][model_name][fluid_label] = @benchmarkable Clapeyron.PH.temperature($model, $p, $h_vapour, $z)

        Suite["PH.entropy"]["two-phase"][model_name] = BenchmarkGroup()
        Suite["PH.entropy"]["two-phase"][model_name][fluid_label] = @benchmarkable Clapeyron.PH.entropy($model, $p, $h_two_phase, $z)

        Suite["PH.entropy"]["liquid-phase"][model_name] = BenchmarkGroup()
        Suite["PH.entropy"]["liquid-phase"][model_name][fluid_label] = @benchmarkable Clapeyron.PH.entropy($model, $p, $h_liquid, $z)

        Suite["PH.entropy"]["vapour-phase"][model_name] = BenchmarkGroup()
        Suite["PH.entropy"]["vapour-phase"][model_name][fluid_label] = @benchmarkable Clapeyron.PH.entropy($model, $p, $h_vapour, $z)
    end
    nothing
end

function add_pure_ph_benchmarks!(Suite::BenchmarkGroup, model_name, model, p, z, fluid_label)
    Tsat = saturation_temperature(model, p)[1]

    hb = enthalpy(model, p, Tsat, z; phase=:l)
    hd = enthalpy(model, p, Tsat, z; phase=:v)
    h_two_phase = (hb + hd) / 2

    T_liquid = Tsat - 10
    T_vapour = Tsat + 10
    h_liquid = enthalpy(model, p, T_liquid, z; phase=:l)
    h_vapour = enthalpy(model, p, T_vapour, z; phase=:v)

    Suite["PH.temperature"]["two-phase"][model_name] = BenchmarkGroup()
    Suite["PH.temperature"]["two-phase"][model_name][fluid_label] = @benchmarkable Clapeyron.PH.temperature($model, $p, $h_two_phase, $z)

    Suite["PH.temperature"]["liquid-phase"][model_name] = BenchmarkGroup()
    Suite["PH.temperature"]["liquid-phase"][model_name][fluid_label] = @benchmarkable Clapeyron.PH.temperature($model, $p, $h_liquid, $z)

    Suite["PH.temperature"]["vapour-phase"][model_name] = BenchmarkGroup()
    Suite["PH.temperature"]["vapour-phase"][model_name][fluid_label] = @benchmarkable Clapeyron.PH.temperature($model, $p, $h_vapour, $z)

    Suite["PH.entropy"]["two-phase"][model_name] = BenchmarkGroup()
    Suite["PH.entropy"]["two-phase"][model_name][fluid_label] = @benchmarkable Clapeyron.PH.entropy($model, $p, $h_two_phase, $z)

    Suite["PH.entropy"]["liquid-phase"][model_name] = BenchmarkGroup()
    Suite["PH.entropy"]["liquid-phase"][model_name][fluid_label] = @benchmarkable Clapeyron.PH.entropy($model, $p, $h_liquid, $z)

    Suite["PH.entropy"]["vapour-phase"][model_name] = BenchmarkGroup()
    Suite["PH.entropy"]["vapour-phase"][model_name][fluid_label] = @benchmarkable Clapeyron.PH.entropy($model, $p, $h_vapour, $z)
    nothing
end
