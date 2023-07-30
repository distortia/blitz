defmodule Blitz.Case do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Blitz.Factory
      import Mox
    end
  end
end
