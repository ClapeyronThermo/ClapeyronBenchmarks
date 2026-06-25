using BenchmarkTools
using Clapeyron
const Suite = BenchmarkGroup()

include("common.jl")
include("first_call.jl")
include("basic_properties.jl")
include("bulk_properties.jl")
include("single_phase_properties.jl")
include("electrolyte_properties.jl")
include("multiphase_properties.jl")

first_results = first_call_benchmarks()
add_all_benchmarks!(Suite)

tune!(Suite; seconds=2.0)
suite_results = run(Suite)
results = (first_results, suite_results)
