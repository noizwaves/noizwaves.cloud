# Beszel

1. `mkdir -p ~/cloud-data/beszel`
1. `docker compose up -d hub`
1. Open [Beszel](https://beszel.noizwaves.cloud)

## Intel GPU monitoring on ODROID

The agent uses Beszel's Intel image, `/dev/dri` access, and `PERFMON` to
collect GPU engine utilization through `intel_gpu_top` with the i915 driver.
See [Beszel's GPU monitoring guide](https://beszel.dev/guide/gpu).

To apply the configuration on ODROID, run from `~/cloud-config/beszel`:

```sh
ls /dev/dri
docker compose up -d agent
docker compose logs --tail=100 agent
docker compose exec agent intel_gpu_top -s 3000 -l
```

Stop the last command with Ctrl-C. Run a GPU workload, such as an Immich
hardware transcode, and open ODROID's system details in Beszel to check the
GPU Engines chart after the next collection interval. Idle engines can show 0%.

If device detection fails, list devices with
`docker compose exec agent intel_gpu_top -L`, then set
`INTEL_GPU_DEVICE=drm:/dev/dri/card0` in `.env`, using the actual card path,
and recreate the agent with `docker compose up -d agent`.

If the logs report performance counter permission errors, consult the guide's
`perf_event_paranoid` troubleshooting before changing host kernel settings.
