defmodule PtcWeb.CalendarLive do
  use PtcWeb, :live_view

  alias Ptc.Events

  @impl true
  def mount(_params, _session, socket) do
    today = Date.utc_today()

    socket =
      socket
      |> assign(:current_date, today)
      |> assign(:year, today.year)
      |> assign(:current_month, today.month)
      |> assign(:selected_date, today)
      |> assign(:selected_event, nil)
      |> load_events()

    {:ok, socket}
  end

  @impl true
  def handle_event("select_date", %{"date" => date_string}, socket) do
    case Date.from_iso8601(date_string) do
      {:ok, date} ->
        {:noreply, assign(socket, :selected_date, date)}

      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("select_event", %{"id" => id}, socket) do
    event = Events.get_event!(id)
    {:noreply, assign(socket, :selected_event, event)}
  end

  @impl true
  def handle_event("close_details", _params, socket) do
    {:noreply, assign(socket, :selected_event, nil)}
  end

  defp load_events(socket) do
    events = Events.list_events()
    events_by_date = group_events_by_date(events)

    assign(socket, :events_by_date, events_by_date)
  end

  defp group_events_by_date(events) do
    Enum.reduce(events, %{}, fn event, acc ->
      if event.start_date do
        end_date = event.end_date || event.start_date
        dates = date_range(event.start_date, end_date)

        Enum.reduce(dates, acc, fn date, acc_inner ->
          date_key = Date.to_string(date)
          Map.update(acc_inner, date_key, [event], fn existing -> [event | existing] end)
        end)
      else
        acc
      end
    end)
  end

  defp date_range(start_date, end_date) do
    days_diff = Date.diff(end_date, start_date)

    if days_diff >= 0 do
      Enum.map(0..days_diff, fn day_offset ->
        Date.add(start_date, day_offset)
      end)
    else
      [start_date]
    end
  end

  defp calendar_days(year, month) do
    first_day = Date.new!(year, month, 1)
    last_day = Date.end_of_month(first_day)
    days_in_month = last_day.day

    day_of_week = Date.day_of_week(first_day)

    leading_blanks = day_of_week - 1

    days =
      Enum.map(1..days_in_month, fn day ->
        Date.new!(year, month, day)
      end)

    List.duplicate(nil, leading_blanks) ++ days
  end

  defp month_name(month) do
    [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ]
    |> Enum.at(month - 1)
  end

  defp event_color(index) do
    colors = [
      "bg-blue-600",
      "bg-purple-600",
      "bg-pink-600",
      "bg-rose-600",
      "bg-orange-600",
      "bg-emerald-600",
      "bg-cyan-600",
      "bg-indigo-600"
    ]

    color_index = rem(index, length(colors))
    Enum.at(colors, color_index)
  end

  defp event_position(event, date) do
    start_date = event.start_date
    end_date = event.end_date || start_date

    cond do
      Date.compare(date, start_date) == :eq && Date.compare(date, end_date) == :eq ->
        :single

      Date.compare(date, start_date) == :eq ->
        :start

      Date.compare(date, end_date) == :eq ->
        :end

      Date.compare(date, start_date) == :gt && Date.compare(date, end_date) == :lt ->
        :middle

      true ->
        :single
    end
  end
end
