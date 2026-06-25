function first_call_benchmarks()
    first_results = NamedTuple[]

    common = BenchmarkSystems.common
    common_label = join(common.components, "/")

    elapsed = @elapsed vap_pr = PR(common.components)
    push!(first_results, first_metric_row(["PR", "BasicIdeal", "PR", common_label], elapsed, "s"))

    elapsed = @elapsed m_tcpr = tcPR(common.components)
    push!(first_results, first_metric_row(["tcPR", "BasicIdeal", "tcPR", common_label], elapsed, "s"))

    elapsed = @elapsed m_vtpr = VTPR(common.components)
    push!(first_results, first_metric_row(["VTPR", "BasicIdeal", "VTPR", common_label], elapsed, "s"))

    elapsed = @elapsed m_cpa = CPA(common.components; assoc_options=AssocOptions(combining=:esd))
    push!(first_results, first_metric_row(["CPA", "BasicIdeal", "CPA", common_label], elapsed, "s"))

    elapsed = @elapsed m_cksaft = CKSAFT(common.components)
    push!(first_results, first_metric_row(["CKSAFT", "BasicIdeal", "CKSAFT", common_label], elapsed, "s"))

    elapsed = @elapsed m_saftvrmie = SAFTVRMie(common.components)
    push!(first_results, first_metric_row(["SAFTVRMie", "BasicIdeal", "SAFTVRMie", common_label], elapsed, "s"))

    elapsed = @elapsed m_saftgammamie = SAFTgammaMie(common.saftgammamie_components)
    push!(first_results, first_metric_row(["SAFTgammaMie", "BasicIdeal", "SAFTgammaMie", common_label], elapsed, "s"))

    elapsed = @elapsed liq_nrtl = NRTL(common.components; puremodel=BasicIdeal)
    push!(first_results, first_metric_row(["NRTL", "BasicIdeal", "NRTL", common_label], elapsed, "s"))

    elapsed = @elapsed liq_unifac = UNIFAC(common.components; puremodel=BasicIdeal)
    push!(first_results, first_metric_row(["UNIFAC", "BasicIdeal", "UNIFAC", common_label], elapsed, "s"))

    elapsed = @elapsed m_nrtl_pr = CompositeModel(common.components; liquid=liq_nrtl, fluid=vap_pr)
    push!(first_results, first_metric_row(["NRTL_PR", "BasicIdeal/BasicIdeal", "NRTL_PR", common_label], elapsed, "s"))

    iapws95 = BenchmarkSystems.iapws95
    iapws95_label = join(iapws95.components, "/")

    elapsed = @elapsed m_iapws95 = IAPWS95()
    push!(first_results, first_metric_row(["IAPWS95", "default", "IAPWS95", iapws95_label], elapsed, "s"))

    gerg2008 = BenchmarkSystems.gerg2008
    gerg2008_label = join(gerg2008.components, "/")

    elapsed = @elapsed m_gerg2008 = GERG2008(gerg2008.components)
    push!(first_results, first_metric_row(["GERG2008", "default", "GERG2008", gerg2008_label], elapsed, "s"))

    epcsaft = BenchmarkSystems.epcsaft
    epcsaft_label = join([epcsaft.solvents; epcsaft.ions], "/")

    elapsed = @elapsed m_epcsaft = ePCSAFT(epcsaft.solvents, epcsaft.ions)
    push!(first_results, first_metric_row(["ePCSAFT", "BasicIdeal/pharmaPCSAFT/hsdDH/ConstRSP", "ePCSAFT", epcsaft_label], elapsed, "s"))

    elapsed = @elapsed Tb_pr = bubble_temperature(m_nrtl_pr, common.p, common.z)[1]
    push!(first_results, first_metric_row(["bubble_temperature", "default", "NRTL_PR", common_label], elapsed, "s"))

    elapsed = @elapsed Td_pr = dew_temperature(m_nrtl_pr, common.p, common.z)[1]
    push!(first_results, first_metric_row(["dew_temperature", "default", "NRTL_PR", common_label], elapsed, "s"))

    T_pr = (Tb_pr + Td_pr) / 2

    elapsed = @elapsed pb_nrtl_pr = bubble_pressure(m_nrtl_pr, T_pr, common.z, ActivityBubblePressure())[1]
    push!(first_results, first_metric_row(["bubble_pressure", "ActivityBubblePressure", "NRTL_PR", common_label], elapsed, "s"))

    elapsed = @elapsed pd_nrtl_pr = dew_pressure(m_nrtl_pr, T_pr, common.z, ActivityDewPressure())[1]
    push!(first_results, first_metric_row(["dew_pressure", "ActivityDewPressure", "NRTL_PR", common_label], elapsed, "s"))

    pf_nrtl_pr = √(pb_nrtl_pr * pd_nrtl_pr)

    elapsed = @elapsed flash_nrtl_pr = tp_flash(m_nrtl_pr, pf_nrtl_pr, T_pr, common.z)
    push!(first_results, first_metric_row(["tp_flash", "default", "NRTL_PR", common_label], elapsed, "s"))

    return first_results
end
