use Mix.Config
alias Dogma.Rule

config :dogma,
  exclude: [
    ~r(\Atest/fixtures/)
  ],
  override: [
    %Rule.LineLength{ max_length: 100 }
  ]
