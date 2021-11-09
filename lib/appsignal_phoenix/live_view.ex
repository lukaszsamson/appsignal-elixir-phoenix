defmodule Appsignal.Phoenix.LiveView do
  @tracer Application.get_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Application.get_env(:appsignal, :appsignal_span, Appsignal.Span)
  alias Appsignal.Utils.MapFilter

  def instrument(module, name, socket, fun) do
    instrument(module, name, %{}, socket, fun)
  end

  def instrument(module, name, params, socket, fun) do
    Appsignal.instrument(
      "#{Appsignal.Utils.module_name(module)}##{name}",
      fn span ->
        _ = @span.set_namespace(span, "live_view")

        try do
          fun.()
        catch
          kind, reason ->
            stack = __STACKTRACE__

            @tracer.set_params(MapFilter.filter(params))
            @tracer.set_environment(Appsignal.Metadata.metadata(socket))

            _ =
              span
              |> @span.add_error(kind, reason, stack)
              |> @tracer.close_span()

            @tracer.ignore()
            :erlang.raise(kind, reason, stack)
        else
          result ->
            @tracer.set_params(MapFilter.filter(params))
            @tracer.set_environment(Appsignal.Metadata.metadata(socket))

            result
        end
      end
    )
  end

  def live_view_action(module, name, socket, function) do
    instrument(module, name, socket, function)
  end

  def live_view_action(module, name, params, socket, function) do
    instrument(module, name, params, socket, function)
  end
end
