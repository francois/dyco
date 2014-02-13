module Dyco
  class Builder
    def initialize(hash)
      @declarations = hash.fetch("declarations")
      @tables       = hash.fetch("tables")
    end

    def column(name)
      declarations.fetch(name)
    end
  end
end
