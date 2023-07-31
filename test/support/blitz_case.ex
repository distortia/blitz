defmodule Blitz.Case do
  @moduledoc false
  use ExUnit.CaseTemplate

  using do
    quote do
      import Blitz.Factory
      import Mox
      import ShorterMaps
    end
  end
end
