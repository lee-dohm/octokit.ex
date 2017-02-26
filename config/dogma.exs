use Mix.Config
alias Dogma.Rule

config :dogma,
  exclude: [
    ~r(\Atest/fixtures/),
    ~r(\Aspec/fixtures/)
  ],
  override: [
    %Rule.LineLength{ max_length: 100 }
  ]
