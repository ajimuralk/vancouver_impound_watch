defmodule VancouverImpoundWatch.Fetcher.Behaviour do
  @moduledoc """
  Behaviour for modules that fetch impound data.
  """

  alias VancouverImpoundWatch.Pet

  @callback get() ::
              {:ok, [Pet.t()]}
              | {:error, {:unexpected_response, integer()}}
              | {:error, String.t()}
end
