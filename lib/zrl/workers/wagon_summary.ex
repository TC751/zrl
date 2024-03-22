defmodule Zrl.Workers.WagonSummary do
  alias Zrl.SystemUtilities
  @wagon_symbols ~w(I D K TP FC H TM SV NT L B BVK X HT HS NB TV TF TA TW XS NC NR)
  @wagon_domains ~w(DRC	RSA	BBR	TRZ)

  def generate() do
    details = prepare_details()
    template = read_template()

    template
    |> :bbmustache.render(details, key_type: :binary)
    |> PdfGenerator.generate_binary!(
      page_width: "11.695",
      page_height: "8.26772",
      shell_params: ["--orientation", "landscape"]
    )
  end

  defp read_template() do
    html =
      Application.app_dir(:zrl, "priv/static/pdf_templates/wagon_summary.html.eex")
      |> File.read!()

    current_admin = SystemUtilities.list_company_info().current_railway_admin
    log_admin = SystemUtilities.list_company_info().log_admin_id
    all_zrl_wagons = SystemUtilities.zrl_wagon_lookup_by_symbol(current_admin)
    zrl_total_wagons = SystemUtilities.all_zrl_wagon_lookup_by_symbol(current_admin)

    zrl_good_wagons =
      SystemUtilities.zrl_go_wagon_lookup_by_symbol(current_admin)
      |> Enum.reject(&(&1.is_usable != "Y"))

    zrl_og_by_domain =
      SystemUtilities.zrl_wagon_lookup_by_domain(current_admin)
      |> Enum.reject(&(&1.is_usable != "Y"))

    log_og_by_domain = SystemUtilities.zrl_wagon_lookup_by_domain(log_admin)
    zrl_wagon_load_status = SystemUtilities.zrl_lookup_by_load_status(current_admin)
    all_go_wagon_lookup = SystemUtilities.all_go_wagon_lookup()

    zrl_wagons =
      Enum.reduce(@wagon_symbols, [], fn symbol, summary ->
        wagon_count =
          all_zrl_wagons
          |> Enum.find(%{wagons: 0}, fn map -> map.symbol == symbol end)
          |> Map.get(:wagons)

        summary ++ [{symbol, wagon_count}]
      end)

    zrl_loaded_wagons_all =
      Enum.reduce(@wagon_symbols, [], fn symbol, summary ->
        wagon_count =
          all_zrl_wagons
          |> Enum.reject(&(&1.load_status != "L"))
          |> Enum.find(%{wagons: 0}, fn map -> map.symbol == symbol end)
          |> Map.get(:wagons)

        summary ++ [{symbol, wagon_count}]
      end)

    zrl_empty_wagons_all =
      Enum.reduce(@wagon_symbols, [], fn symbol, summary ->
        wagon_count =
          all_zrl_wagons
          |> Enum.reject(&(&1.load_status != "E"))
          |> Enum.find(%{wagons: 0}, fn map -> map.symbol == symbol end)
          |> Map.get(:wagons)

        summary ++ [{symbol, wagon_count}]
      end)

    zrl_wagon_fleet =
      Enum.reduce(@wagon_symbols, [], fn symbol, summary ->
        wagon_count =
          zrl_total_wagons
          |> Enum.find(%{wagons: 0}, fn map -> map.symbol == symbol end)
          |> Map.get(:wagons)

        summary ++ [{symbol, wagon_count}]
      end)

    zrl_go_wagons =
      Enum.reduce(@wagon_symbols, [], fn symbol, summary ->
        wagon_count =
          zrl_good_wagons
          |> Enum.find(%{wagons: 0}, fn map -> map.symbol == symbol end)
          |> Map.get(:wagons)

        summary ++ [{symbol, wagon_count}]
      end)

    zrl_empty_wagons_by_domain =
      Enum.reduce(@wagon_domains, [], fn domain, summary ->
        wagon_count =
          zrl_og_by_domain
          |> Enum.reject(&(&1.load_status != "E"))
          |> Enum.find(%{wagons: 0}, fn map -> map.domain == domain end)
          |> Map.get(:wagons)

        summary ++ [{domain, wagon_count}]
      end)

    zrl_loaded_wagons_by_domain =
      Enum.reduce(@wagon_domains, [], fn domain, summary ->
        wagon_count =
          zrl_og_by_domain
          |> Enum.reject(&(&1.load_status != "L"))
          |> Enum.find(%{wagons: 0}, fn map -> map.domain == domain end)
          |> Map.get(:wagons)

        summary ++ [{domain, wagon_count}]
      end)

    log_empty_wagons_by_domain =
      Enum.reduce(@wagon_domains, [], fn domain, summary ->
        wagon_count =
          log_og_by_domain
          |> Enum.reject(&(&1.load_status != "E"))
          |> Enum.find(%{wagons: 0}, fn map -> map.domain == domain end)
          |> Map.get(:wagons)

        summary ++ [{domain, wagon_count}]
      end)

    log_loaded_wagons_by_domain =
      Enum.reduce(@wagon_domains, [], fn domain, summary ->
        wagon_count =
          log_og_by_domain
          |> Enum.reject(&(&1.load_status != "L"))
          |> Enum.find(%{wagons: 0}, fn map -> map.domain == domain end)
          |> Map.get(:wagons)

        summary ++ [{domain, wagon_count}]
      end)

    all_admins_og_wagons =
      Enum.reduce(all_go_wagon_lookup |> Enum.reject(&(&1.is_usable != "Y")), 0, fn item, acc ->
        item.wagons + acc
      end)

    total_log_og_wagons_by_domain =
      Enum.reduce(log_og_by_domain |> Enum.reject(&(&1.is_usable != "Y")), 0, fn item, acc ->
        item.wagons + acc
      end)

    total_log_wagons_by_domain =
      Enum.reduce(log_og_by_domain, 0, fn item, acc -> item.wagons + acc end)

    total_zrl_loaded_wagons_by_domain =
      Enum.reduce(zrl_loaded_wagons_by_domain, 0, fn {_, count}, acc -> count + acc end)

    total_log_empty_wagons_by_domain =
      Enum.reduce(log_empty_wagons_by_domain, 0, fn {_, count}, acc -> count + acc end)

    total_log_loaded_wagons_by_domain =
      Enum.reduce(log_loaded_wagons_by_domain, 0, fn {_, count}, acc -> count + acc end)

    total_zrl_empty_wagons_by_domain =
      Enum.reduce(zrl_empty_wagons_by_domain, 0, fn {_, count}, acc -> count + acc end)

    zrl_total_fleet = Enum.reduce(zrl_total_wagons, 0, fn item, acc -> item.wagons + acc end)
    zrl_total_go_fleet = Enum.reduce(zrl_good_wagons, 0, fn item, acc -> item.wagons + acc end)

    zrl_total_active =
      Enum.reduce(zrl_wagon_load_status |> Enum.reject(&(&1.mvt_status != "A")), 0, fn item,
                                                                                       acc ->
        item.wagons + acc
      end)

    zrl_total_non_active =
      Enum.reduce(zrl_wagon_load_status |> Enum.reject(&(&1.mvt_status != "N")), 0, fn item,
                                                                                       acc ->
        item.wagons + acc
      end)

    domain_log_header =
      Enum.map(log_empty_wagons_by_domain, fn {domain, _wagon_count} ->
        entry_details = %{
          "domain" => domain
        }

        """
          <td> {{ domain }} </td>
        """
        |> :bbmustache.render(entry_details, key_type: :binary)
      end)

    log_loaded_wagons =
      Enum.map(log_loaded_wagons_by_domain, fn {_domain, wagon_count} ->
        entry_details = %{
          "wagon_count" => wagon_count
        }

        """
          <td> {{ wagon_count }} </td>
        """
        |> :bbmustache.render(entry_details, key_type: :binary)
      end)

    log_empty_wagons =
      Enum.map(log_empty_wagons_by_domain, fn {_domain, wagon_count} ->
        entry_details = %{
          "wagon_count" => wagon_count
        }

        """
          <td> {{ wagon_count }} </td>
        """
        |> :bbmustache.render(entry_details, key_type: :binary)
      end)

    zrl_loaded_wagons =
      Enum.map(zrl_loaded_wagons_by_domain, fn {_domain, wagon_count} ->
        entry_details = %{
          "wagon_count" => wagon_count
        }

        """
          <td> {{ wagon_count }} </td>
        """
        |> :bbmustache.render(entry_details, key_type: :binary)
      end)

    zrl_empty_wagons =
      Enum.map(zrl_empty_wagons_by_domain, fn {_domain, wagon_count} ->
        entry_details = %{
          "wagon_count" => wagon_count
        }

        """
          <td> {{ wagon_count }} </td>
        """
        |> :bbmustache.render(entry_details, key_type: :binary)
      end)

    wagon_symbols =
      Enum.map(zrl_wagons, fn {symbol, _wagon_count} ->
        entry_details = %{
          "symbol" => symbol
        }

        """
          <td> {{ symbol }} </td>
        """
        |> :bbmustache.render(entry_details, key_type: :binary)
      end)

    zrl_go_wagons =
      Enum.map(zrl_go_wagons, fn {_symbol, wagon_count} ->
        entry_details = %{
          "wagon_count" => wagon_count
        }

        """
          <td> {{ wagon_count }} </td>
        """
        |> :bbmustache.render(entry_details, key_type: :binary)
      end)

    zrl_wagon_fleet =
      Enum.map(zrl_wagon_fleet, fn {_symbol, wagon_count} ->
        entry_details = %{
          "wagon_count" => wagon_count
        }

        """
          <td> {{ wagon_count }} </td>
        """
        |> :bbmustache.render(entry_details, key_type: :binary)
      end)

    zrl_loaded_wagons_all =
      Enum.map(zrl_loaded_wagons_all, fn {_symbol, wagon_count} ->
        entry_details = %{
          "wagon_count" => wagon_count
        }

        """
          <td> {{ wagon_count }} </td>
        """
        |> :bbmustache.render(entry_details, key_type: :binary)
      end)

    zrl_empty_wagons_all =
      Enum.map(zrl_empty_wagons_all, fn {_symbol, wagon_count} ->
        entry_details = %{
          "wagon_count" => wagon_count
        }

        """
          <td> {{ wagon_count }} </td>
        """
        |> :bbmustache.render(entry_details, key_type: :binary)
      end)

    total_zrl_loaded_wagons_by_domain =
      total_zrl_loaded_wagons_by_domain(total_zrl_loaded_wagons_by_domain)

    total_zrl_empty_wagons_by_domain =
      total_zrl_empty_wagons_by_domain(total_zrl_empty_wagons_by_domain)

    total_log_loaded_wagons_by_domain =
      total_log_loaded_wagons_by_domain(total_log_loaded_wagons_by_domain)

    total_log_empty_wagons_by_domain =
      total_log_empty_wagons_by_domain(total_log_empty_wagons_by_domain)

    zrl_total_fleet = zrl_total_fleet(zrl_total_fleet)
    zrl_total_go_fleet = zrl_total_go_fleet(zrl_total_go_fleet)
    zrl_total_active = zrl_total_active(zrl_total_active)
    zrl_total_non_active = zrl_total_non_active(zrl_total_non_active)
    total_log_wagons_by_domain = total_log_wagons_by_domain(total_log_wagons_by_domain)
    total_log_og_wagons_by_domain = total_log_og_wagons_by_domain(total_log_og_wagons_by_domain)
    all_admins_og_wagons = all_admins_og_wagons(all_admins_og_wagons)

    domain_log_header = "" <> Enum.join(domain_log_header, "") <> ""
    html = String.replace(html, "</log_header>", domain_log_header)
    log_loaded_wagons = "" <> Enum.join(log_loaded_wagons, "") <> ""
    html = String.replace(html, "</log_loaded>", log_loaded_wagons)
    log_empty_wagons = "" <> Enum.join(log_empty_wagons, "") <> ""
    html = String.replace(html, "</log_empty>", log_empty_wagons)
    zrl_loaded_wagons = "" <> Enum.join(zrl_loaded_wagons, "") <> ""
    html = String.replace(html, "</zrl_loaded>", zrl_loaded_wagons)
    zrl_empty_wagons = "" <> Enum.join(zrl_empty_wagons, "") <> ""
    html = String.replace(html, "</zrl_empty>", zrl_empty_wagons)
    wagon_symbols = "" <> Enum.join(wagon_symbols, "") <> ""
    html = String.replace(html, "</Symbols>", wagon_symbols)
    zrl_go_wagons = "" <> Enum.join(zrl_go_wagons, "") <> ""
    html = String.replace(html, "</zrl_go_wagons>", zrl_go_wagons)
    zrl_wagon_fleet = "" <> Enum.join(zrl_wagon_fleet, "") <> ""
    html = String.replace(html, "</zrl_wagon_fleet>", zrl_wagon_fleet)
    zrl_loaded_wagons_all = "" <> Enum.join(zrl_loaded_wagons_all, "") <> ""
    html = String.replace(html, "</zrl_loaded_wagons_all>", zrl_loaded_wagons_all)
    zrl_empty_wagons_all = "" <> Enum.join(zrl_empty_wagons_all, "") <> ""
    html = String.replace(html, "</zrl_empty_wagons_all>", zrl_empty_wagons_all)

    html =
      String.replace(
        html,
        "</total_zrl_loaded_wagons_by_domain>",
        total_zrl_loaded_wagons_by_domain
      )

    html =
      String.replace(
        html,
        "</total_zrl_empty_wagons_by_domain>",
        total_zrl_empty_wagons_by_domain
      )

    html =
      String.replace(
        html,
        "</total_log_empty_wagons_by_domain>",
        total_log_empty_wagons_by_domain
      )

    html =
      String.replace(
        html,
        "</total_log_loaded_wagons_by_domain>",
        total_log_loaded_wagons_by_domain
      )

    html = String.replace(html, "</zrl_total_fleet>", zrl_total_fleet)
    html = String.replace(html, "</zrl_total_go_fleet>", zrl_total_go_fleet)
    html = String.replace(html, "</zrl_total_active>", zrl_total_active)
    html = String.replace(html, "</zrl_total_non_active>", zrl_total_non_active)
    html = String.replace(html, "</total_log_wagons_by_domain>", total_log_wagons_by_domain)
    html = String.replace(html, "</total_log_og_wagons_by_domain>", total_log_og_wagons_by_domain)
    String.replace(html, "</all_admins_og_wagons>", all_admins_og_wagons)
  end

  defp total_zrl_loaded_wagons_by_domain(total) do
    entry_details = %{
      "wagon_count" => Number.Delimit.number_to_delimited(total || 0, precision: 0)
    }

    """
      <td> {{ wagon_count }} </td>
    """
    |> :bbmustache.render(entry_details, key_type: :binary)
  end

  defp total_zrl_empty_wagons_by_domain(total) do
    entry_details = %{
      "wagon_count" => Number.Delimit.number_to_delimited(total || 0, precision: 0)
    }

    """
      <td> {{ wagon_count }} </td>
    """
    |> :bbmustache.render(entry_details, key_type: :binary)
  end

  defp total_log_loaded_wagons_by_domain(total) do
    entry_details = %{
      "wagon_count" => Number.Delimit.number_to_delimited(total || 0, precision: 0)
    }

    """
      <td> {{ wagon_count }} </td>
    """
    |> :bbmustache.render(entry_details, key_type: :binary)
  end

  defp total_log_empty_wagons_by_domain(total) do
    entry_details = %{
      "wagon_count" => Number.Delimit.number_to_delimited(total || 0, precision: 0)
    }

    """
      <td> {{ wagon_count }} </td>
    """
    |> :bbmustache.render(entry_details, key_type: :binary)
  end

  defp zrl_total_fleet(total) do
    entry_details = %{
      "wagon_count" => Number.Delimit.number_to_delimited(total || 0, precision: 0)
    }

    """
      <td> {{ wagon_count }} </td>
    """
    |> :bbmustache.render(entry_details, key_type: :binary)
  end

  defp zrl_total_go_fleet(total) do
    entry_details = %{
      "wagon_count" => Number.Delimit.number_to_delimited(total || 0, precision: 0)
    }

    """
      <td> {{ wagon_count }} </td>
    """
    |> :bbmustache.render(entry_details, key_type: :binary)
  end

  defp zrl_total_active(total) do
    entry_details = %{
      "wagon_count" => Number.Delimit.number_to_delimited(total || 0, precision: 0)
    }

    """
      <td> {{ wagon_count }} </td>
    """
    |> :bbmustache.render(entry_details, key_type: :binary)
  end

  defp zrl_total_non_active(total) do
    entry_details = %{
      "wagon_count" => Number.Delimit.number_to_delimited(total || 0, precision: 0)
    }

    """
      <td> {{ wagon_count }} </td>
    """
    |> :bbmustache.render(entry_details, key_type: :binary)
  end

  defp total_log_wagons_by_domain(total) do
    entry_details = %{
      "wagon_count" => Number.Delimit.number_to_delimited(total || 0, precision: 0)
    }

    """
      <td> {{ wagon_count }} </td>
    """
    |> :bbmustache.render(entry_details, key_type: :binary)
  end

  defp all_admins_og_wagons(total) do
    entry_details = %{
      "wagon_count" => Number.Delimit.number_to_delimited(total || 0, precision: 0)
    }

    """
      <td style="color:red; font-weight:900"> {{ wagon_count }} </td>
    """
    |> :bbmustache.render(entry_details, key_type: :binary)
  end

  defp total_log_og_wagons_by_domain(total) do
    entry_details = %{
      "wagon_count" => Number.Delimit.number_to_delimited(total || 0, precision: 0)
    }

    """
      <td> {{ wagon_count }} </td>
    """
    |> :bbmustache.render(entry_details, key_type: :binary)
  end

  def prepare_details() do
    company = Zrl.SystemUtilities.list_company_info()

    %{
      "date" => Timex.format!(Timex.today(), "%A, %B %e, %Y", :strftime),
      "campany_name" => company.company_name,
      "company_address" => company.company_address
    }
  end
end
