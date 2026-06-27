import Dates

using DBInterface, SQLite

const Schema_Version = "4"

iso_utc_now() = Dates.format(Dates.now(Dates.UTC), dateformat"yyyy-mm-ddTHH:MM:SS.sss") * "Z"

function shard_paths(root::AbstractString)
    paths = String[]
    for (dir, _, files) in walkdir(root)
        for file in files
            endswith(file, ".sqlite") && push!(paths, joinpath(dir, file))
        end
    end
    sort!(paths)
end

function schema_version(path::AbstractString)
    db = SQLite.DB(path)
    try
        row = iterate(DBInterface.execute(db, "SELECT value FROM benchledger_metadata WHERE key = 'schema_version'"))
        row === nothing && error("Missing benchledger_metadata.schema_version in $(path).")
        String(row[1].value)
    finally
        close(db)
    end
end

function ensure_compatible_target!(path::AbstractString)
    isfile(path) || return false
    version = schema_version(path)
    version == Schema_Version || error("Unsupported target schema version in $(path): $(version). Expected $(Schema_Version).")
    true
end

function merge_shard!(db::SQLite.DB, path::AbstractString, alias::AbstractString)
    escaped_path = replace(path, "'" => "''")
    SQLite.execute(db, "ATTACH DATABASE '$(escaped_path)' AS $(alias)")
    try
        SQLite.execute(db, "BEGIN IMMEDIATE TRANSACTION")
        SQLite.execute(db, "INSERT OR IGNORE INTO benchmark_code_states SELECT * FROM $(alias).benchmark_code_states")
        SQLite.execute(db, "INSERT OR IGNORE INTO benchmark_environments SELECT * FROM $(alias).benchmark_environments")
        SQLite.execute(db, "INSERT OR IGNORE INTO benchmark_runs SELECT * FROM $(alias).benchmark_runs")
        SQLite.execute(db, "INSERT OR IGNORE INTO benchmark_results SELECT * FROM $(alias).benchmark_results")
        SQLite.execute(db, "COMMIT")
    catch
        SQLite.execute(db, "ROLLBACK")
        rethrow()
    finally
        SQLite.execute(db, "DETACH DATABASE $(alias)")
    end
end

target_path = abspath(get(ENV, "BENCH_DB_PATH", error("BENCH_DB_PATH is required.")))
shard_dir = abspath(get(ENV, "BENCH_SHARD_DIR", error("BENCH_SHARD_DIR is required.")))
paths = shard_paths(shard_dir)
isempty(paths) && error("No shard databases found in $(shard_dir).")

for path in paths
    version = schema_version(path)
    version == Schema_Version || error("Unsupported shard schema version in $(path): $(version). Expected $(Schema_Version).")
end

mkpath(dirname(target_path))
target_exists = ensure_compatible_target!(target_path)
if !target_exists
    cp(first(paths), target_path; force=true)
end

db = SQLite.DB(target_path)
try
    SQLite.execute(db, "PRAGMA foreign_keys=ON")
    SQLite.execute(db, "PRAGMA journal_mode=WAL")
    SQLite.execute(db, "PRAGMA synchronous=NORMAL")
    merge_paths = target_exists ? paths : paths[2:end]
    for (index, path) in enumerate(merge_paths)
        merge_shard!(db, path, "shard$(index)")
    end
    DBInterface.execute(db, """
INSERT INTO benchledger_metadata (key, value)
VALUES ('updated_at', ?)
ON CONFLICT (key) DO UPDATE SET value = excluded.value
""", (iso_utc_now(),))
    SQLite.execute(db, "PRAGMA wal_checkpoint(TRUNCATE)")
finally
    close(db)
end

println("Merged $(length(paths)) shard databases into $(target_path)")
