defmodule PostalDistrictProfiler do
	import ExProf.Macro

	def run do
		country = String.to_atom("dk")
    category = String.to_atom("lease")
    profile do
      # Postalex.Service.PostalDistrict.all(country, category)
    	Postalex.Service.PostalDistrict.all(country, category)
    end
	end

end
PostalDistrictProfiler.run
