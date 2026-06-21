# Benchmark Group Protocol:
# Function + Secondary param + Property method + specific materials
using Clapeyron

function make_composite(comps, liquid, fluid)
    try
        return CompositeModel(comps; liquid=liquid, fluid=fluid)
    catch
        return CompositeModel(comps, liquid=liquid, fluid=fluid)
    end
end

function first_metric_row(path::Vector{String}, value::Real, unit::String)
    return (
        benchmark_path=path,
        metric_name="time",
        statistic="first",
        unit=unit,
        value=Float64(value),
        better="lower",
    )
end

const comps_pr = ["propane", "n-butane", "n-pentane", "n-hexane"]
const z_pr = [0.15, 0.35, 0.30, 0.20]
const p_pr = 5.0e5

const comps_nrtl_pr = ["water", "methanol", "ethanol", "acetone"]
const z_nrtl_pr = [0.35, 0.25, 0.20, 0.20]
const T_nrtl_pr = 333.15

m_pr = nothing
liq_nrtl = nothing
vap_pr = nothing
m_nrtl_pr = nothing
Tb_pr = 0.0
Td_pr = 0.0
pb_nrtl_pr = 0.0
pd_nrtl_pr = 0.0

# Test the time of first call

first_results = NamedTuple[]

first_s = @elapsed m_pr = PR(comps_pr)
push!(first_results, first_metric_row(["PR", "BasicIdeal", "PR", "propane/n-butane/n-pentane/n-hexane"], first_s, "s"))

first_s = @elapsed liq_nrtl = NRTL(comps_nrtl_pr; puremodel=BasicIdeal)
push!(first_results, first_metric_row(["NRTL", "BasicIdeal", "NRTL", "water/methanol/ethanol/acetone"], first_s, "s"))

first_s = @elapsed vap_pr = PR(comps_nrtl_pr)
push!(first_results, first_metric_row(["PR", "BasicIdeal", "PR", "water/methanol/ethanol/acetone"], first_s, "s"))

first_s = @elapsed m_nrtl_pr = make_composite(comps_nrtl_pr, liq_nrtl, vap_pr)
push!(first_results, first_metric_row(["NRTL_PR", "BasicIdeal/BasicIdeal", "NRTL_PR", "water/methanol/ethanol/acetone"], first_s, "s"))

first_s = @elapsed Tb_pr = bubble_temperature(m_pr, p_pr, z_pr)[1]
push!(first_results, first_metric_row(["bubble_temperature", "default", "PR", "propane/n-butane/n-pentane/n-hexane"], first_s, "s"))

first_s = @elapsed Td_pr = dew_temperature(m_pr, p_pr, z_pr)[1]
push!(first_results, first_metric_row(["dew_temperature", "default", "PR", "propane/n-butane/n-pentane/n-hexane"], first_s, "s"))

Tf_pr = 0.5 * (Tb_pr + Td_pr)
first_s = @elapsed tp_flash(m_pr, p_pr, Tf_pr, z_pr)
push!(first_results, first_metric_row(["tp_flash", "default", "PR", "propane/n-butane/n-pentane/n-hexane"], first_s, "s"))

first_s = @elapsed pb_nrtl_pr = bubble_pressure(m_nrtl_pr, T_nrtl_pr, z_nrtl_pr, ActivityBubblePressure())[1]
push!(first_results, first_metric_row(["bubble_pressure", "ActivityBubblePressure", "NRTL_PR", "water/methanol/ethanol/acetone"], first_s, "s"))

first_s = @elapsed pd_nrtl_pr = dew_pressure(m_nrtl_pr, T_nrtl_pr, z_nrtl_pr, ActivityDewPressure())[1]
push!(first_results, first_metric_row(["dew_pressure", "ActivityDewPressure", "NRTL_PR", "water/methanol/ethanol/acetone"], first_s, "s"))

pf_nrtl_pr = sqrt(pb_nrtl_pr * pd_nrtl_pr)
first_s = @elapsed tp_flash(m_nrtl_pr, pf_nrtl_pr, T_nrtl_pr, z_nrtl_pr)
push!(first_results, first_metric_row(["tp_flash", "default", "NRTL_PR", "water/methanol/ethanol/acetone"], first_s, "s"))

# Test regular call time

const Suite = BenchmarkGroup()

Suite["bubble_temperature"] = BenchmarkGroup()
Suite["bubble_temperature"]["default"] = BenchmarkGroup()
Suite["bubble_temperature"]["default"]["PR"] = BenchmarkGroup()
Suite["bubble_temperature"]["default"]["PR"]["propane/n-butane/n-pentane/n-hexane"] = @benchmarkable bubble_temperature($m_pr, $p_pr, $z_pr)

Suite["dew_temperature"] = BenchmarkGroup()
Suite["dew_temperature"]["default"] = BenchmarkGroup()
Suite["dew_temperature"]["default"]["PR"] = BenchmarkGroup()
Suite["dew_temperature"]["default"]["PR"]["propane/n-butane/n-pentane/n-hexane"] = @benchmarkable dew_temperature($m_pr, $p_pr, $z_pr)

Suite["tp_flash"] = BenchmarkGroup()
Suite["tp_flash"]["default"] = BenchmarkGroup()
Suite["tp_flash"]["default"]["PR"] = BenchmarkGroup()
Suite["tp_flash"]["default"]["PR"]["propane/n-butane/n-pentane/n-hexane"] = @benchmarkable tp_flash($m_pr, $p_pr, $Tf_pr, $z_pr)
Suite["tp_flash"]["default"]["NRTL_PR"] = BenchmarkGroup()
Suite["tp_flash"]["default"]["NRTL_PR"]["water/methanol/ethanol/acetone"] = @benchmarkable tp_flash($m_nrtl_pr, $pf_nrtl_pr, $T_nrtl_pr, $z_nrtl_pr)

Suite["bubble_pressure"] = BenchmarkGroup()
Suite["bubble_pressure"]["ActivityBubblePressure"] = BenchmarkGroup()
Suite["bubble_pressure"]["ActivityBubblePressure"]["NRTL_PR"] = BenchmarkGroup()
Suite["bubble_pressure"]["ActivityBubblePressure"]["NRTL_PR"]["water/methanol/ethanol/acetone"] = @benchmarkable bubble_pressure($m_nrtl_pr, $T_nrtl_pr, $z_nrtl_pr, $(ActivityBubblePressure()))

Suite["dew_pressure"] = BenchmarkGroup()
Suite["dew_pressure"]["ActivityDewPressure"] = BenchmarkGroup()
Suite["dew_pressure"]["ActivityDewPressure"]["NRTL_PR"] = BenchmarkGroup()
Suite["dew_pressure"]["ActivityDewPressure"]["NRTL_PR"]["water/methanol/ethanol/acetone"] = @benchmarkable dew_pressure($m_nrtl_pr, $T_nrtl_pr, $z_nrtl_pr, $(ActivityDewPressure()))


include("cubic_two_phase.jl")
tune!(Suite; seconds=2.0)
suite_results = run(Suite)
results = (first_results, suite_results)
