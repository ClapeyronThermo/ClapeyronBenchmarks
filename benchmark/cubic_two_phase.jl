const CUBIC_MODELS = [PR, cPR, SRK, RK, KU, PatelTeja]


"""
benchmarking two phase falsh computations for cubic eos
"""
function cubic_ph_flash(SUITE::BenchmarkGroup)
    # cubics = [cPR, SRK, KU] 
    fluids = ["pentane", "isopentane"] # High glide
    p0 = 101325
    z0 = [1.0, 1.0]
    SUITE["PH_FLASH"] = BenchmarkGroup()

    T_dew(model) = dew_temperature(model, p0, z0)[1]
    T_bub(model) = bubble_temperature(model, p0, z0)[1]

    for eos_constructor in CUBIC_MODELS
    m_ = eos_constructor(fluids; idealmodel = ReidIdeal)
    Tb = T_bub(m_)
    Td = T_dew(m_)
    hb = enthalpy(m_, p0, Tb, z0)
    hd = enthalpy(m_, p0, Td, z0)
    h_ = (hb+hd)/2
    eos_name = string(eos_constructor)

    SUITE["PH.temperature"] = BenchmarkGroup()
    SUITE["PH.temperature"]["default"] = BenchmarkGroup()
    SUITE["PH.temperature"]["default"][eos_name] = BenchmarkGroup()
    SUITE["PH.temperature"]["default"][eos_name]["pentane/isopentane"] =  @benchmarkable try
            Clapeyron.PH.temperature($m_, $p0,$h_, $z0)
            catch
                 nothing
            end


    SUITE["PH.entropy"] = BenchmarkGroup()
    SUITE["PH.entropy"]["default"] = BenchmarkGroup()
    SUITE["PH.entropy"]["default"][eos_name] = BenchmarkGroup()
    SUITE["PH.entropy"]["default"][eos_name]["pentane/isopentane"]  = @benchmarkable begin
            try
                Clapeyron.PH.entropy($m_, $p0,$h_, $z0)
            catch
                nothing
            end
        end

    hv = enthalpy(m_, p0, Td + 10, z0)
    hl = enthalpy(m_, p0, Tb - 10, z0)
    SUITE["PH.temperature"]["phase=:liquid"] = BenchmarkGroup()
    SUITE["PH.temperature"]["phase=:liquid"][eos_name] = BenchmarkGroup()
    SUITE["PH.temperature"]["phase=:liquid"][eos_name]["pentane/isopentane"] =  @benchmarkable try
                Clapeyron.PH.temperature($m_, $p0,$hl, $z0, phase = :liquid)
            catch
                nothing
            end
    
    SUITE["PH.temperature"]["phase=:gas"] = BenchmarkGroup()
    SUITE["PH.temperature"]["phase=:gas"][eos_name] = BenchmarkGroup()
    SUITE["PH.temperature"]["phase=:gas"][eos_name]["pentane/isopentane"] =  @benchmarkable try
                Clapeyron.PH.temperature($m_, $p0,$hv, $z0, phase = :gas)
            catch
                nothing
            end
    
    SUITE["PH.entropy"]["phase=:liquid"] = BenchmarkGroup()
    SUITE["PH.entropy"]["phase=:liquid"][eos_name] = BenchmarkGroup()
    SUITE["PH.entropy"]["phase=:liquid"][eos_name]["pentane/isopentane"] =  @benchmarkable try
                Clapeyron.PH.entropy($m_, $p0,$hl, $z0, phase = :liquid)
            catch
                nothing
            end
    
    SUITE["PH.entropy"]["phase=:gas"] = BenchmarkGroup()
    SUITE["PH.entropy"]["phase=:gas"][eos_name] = BenchmarkGroup()
    SUITE["PH.entropy"]["phase=:gas"][eos_name]["pentane/isopentane"] =  @benchmarkable try
                Clapeyron.PH.entropy($m_, $p0,$hv, $z0, phase = :gas)
            catch
                nothing
            end


    end
end

if Base.pkgversion(Clapeyron) >= v"0.6.8"
    cubic_ph_flash(SUITE)
end