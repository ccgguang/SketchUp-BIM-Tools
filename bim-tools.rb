#       bim-tools.rb
#       
#       Copyright (C) 2014 Jan Brouwer <jan@brewsky.nl>
#       
#       This program is free software: you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation, either version 3 of the License, or
#       (at your option) any later version.
#       
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#       
#       You should have received a copy of the GNU General Public License
#       along with this program.  If not, see <http://www.gnu.org/licenses/>.

# roadmap:
# columns

# roadmap 0.13:
# fix side-faces normal direction in openings
# fix project properties(different way of reading/writing properties? one at a time instead of array?)
# get rid of entitiesobservers
# improve IFC export
# speed up hidden edges

# Changelog:
# 140804 patch for SketchUp 2014 + some code cleanup and speed improvements from the past year
# 130107 Fixed IFC wall layer thickness
# 130105 Improved ifc export: added ifcwallstandardcase with openings
# 130102 replaced bim-tools class functionality with the module
# 121210 hide edges when source edges are softened
# 121210 update webdialog even if not all entities in selection are bt-entities
# 121205 Added observer manager
# 121205 Added on/off button for observers
# 121120 Removed unnecessary "UTF-8 with BOM" file
# 121120 Updated outdated headers to 2012
# 121120 Split up all double module-declarations
# 121002 Fixed Bt-entities observers inside groups/components
# 120930 BT objects do not lose relastions anymore
# 120928 Added color to FC export
# 120924 improved IFC header
# 120922 fixed double click to re-open dialog
# 120922 fixed multiple models for mac(hopefully)
# 120922 Greatly improved opening and switching of models and hopefully multiple models for mac
# 120920 IFC export walls added 2dCurve representation
# 120918 Fixed ifc export of wall properties
# 120917 Fixed links between ifcproject / ifcsite / ifcbuilding / building objects
# 120916 Fixed saving + exporting of project data
# 120717 Re-implemented basic IFC export(IfcPlate elements only)
# 120603 Added top menu to webdialog
# 120602 Added dialog section for thick faces
# 120602 Added dialog thumbnails
# 120602 Streamlined dialog ui
# 120522 fixed planar geometry origin
# 120522 fixed bug in delete properties, attribute library also gets deleted
# 120517 added option to change planar length and height
# 120515 re-implemented walls from edges function
# 120509 added materials to planars
# 120504 added remove BIM properties button
# 120503 added layer so element connections can be hidden
# 120428 added cutting components
# 120319 recover lost BIM-Tools source faces
# 120314 save BIM-data
# 120312 create holes in planar elements
# 120312 prevent duplicate BIM-Tools entities from source faces
# 120311 show BIM-data for source faces
# 120311 added user input for element thickness using VCB
# 120311 tested webdialog on IE8, works fine, shows min/max-image, but content width is a bit off...
# webdialog show_modal for mac

module Brewsky
  module BimTools

    # Create an entry in the Extension list that loads a script called
    # bim-tools.rb.
    require 'sketchup.rb'
    require 'extensions.rb'

    bimtools = SketchupExtension.new "bim-tools", "bim-tools/bim-tools_loader.rb"
    bimtools.version = '0.12.3'
    bimtools.description = "Tools to create building parts and export these to IFC."
    Sketchup.register_extension bimtools, true
  end # module BimTools
end # module Brewsky
