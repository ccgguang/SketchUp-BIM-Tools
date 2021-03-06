#       clsIfcGeometry.rb
#       
#       Copyright (C) 2012 Jan Brouwer <jan@brewsky.nl>
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

module Brewsky
  module BimTools
  
    # classes for defining purely geometric IFC elements
    
    class IfcExtrudedAreaSolid < IfcBase
      # Attribute	        Type	                          Defined By
      # SweptArea	        IfcProfileDef (ENTITY)	        IfcSweptAreaSolid
      # Position	        IfcAxis2Placement3D (ENTITY)    IfcSweptAreaSolid
      # ExtrudedDirection	IfcDirection (ENTITY)	          IfcExtrudedAreaSolid
      # Depth	            IfcPositiveLengthMeasure (REAL)	IfcExtrudedAreaSolid
      attr_accessor :sweptArea, :position, :extrudedDirection, :depth, :record_nr, :entityType
      def initialize(ifc_exporter, bt_entity, loop, depth=nil)
        @ifc_exporter = ifc_exporter
        @bt_entity = bt_entity
        @loop = loop
        @entityType = "IFCEXTRUDEDAREASOLID"
        @ifc_exporter.add(self)
        
        offset = @bt_entity.offset * -1
        vector = Geom::Vector3d.new 0,0,offset
        @transformation = Geom::Transformation.translation vector
        
        #@transformation = @bt_entity.geometry.transformation
        
        # "local" IFC array
        @a_Attributes = Array.new
        @a_Attributes << set_SweptArea
        @a_Attributes << set_Position
        @a_Attributes << set_ExtrudedDirection(loop)
        @a_Attributes << set_Depth(depth)
      end
      def set_SweptArea
    #85 = IFCARBITRARYCLOSEDPROFILEDEF(.AREA., $, #86);
    #86 = IFCPOLYLINE((#87, #88, #89, #90, #91));
    #87 = IFCCARTESIANPOINT((0., 0.));
    #88 = IFCCARTESIANPOINT((0., 3.000E-1));
    #89 = IFCCARTESIANPOINT((5., 3.000E-1));
    #90 = IFCCARTESIANPOINT((5., 0.));
    #91 = IFCCARTESIANPOINT((0., 0.));
        return IfcArbitraryClosedProfileDef.new(@ifc_exporter, @bt_entity, @loop).record_nr
      end
      def set_Position
        return IfcAxis2Placement3D.new(@ifc_exporter, @transformation).record_nr
      end
      def set_ExtrudedDirection(loop)
        vec = Geom::Vector3d.new(0,0,1) #loop.face.normal.transform @transformation.inverse#@transformation.zaxis#.reverse #
        return IfcDirection.new(@ifc_exporter, vec).record_nr
      end
      def set_Depth(depth=nil)
        if depth.nil?
          return @ifc_exporter.ifcLengthMeasure(@bt_entity.width)
        else
          return @ifc_exporter.ifcLengthMeasure(depth)
        end
      end
    end
    
    class WscIfcExtrudedAreaSolid < IfcExtrudedAreaSolid # special version for ifcwallstandardcase
      attr_accessor :sweptArea, :position, :extrudedDirection, :depth, :record_nr, :entityType
      def initialize(ifc_exporter, bt_entity, loop, depth=nil)
        @ifc_exporter = ifc_exporter
        @bt_entity = bt_entity
        @loop = loop
        @entityType = "IFCEXTRUDEDAREASOLID"
        @ifc_exporter.add(self)
        
        vector = Geom::Vector3d.new 0,0,0
        @transformation = Geom::Transformation.translation vector
        
        # "local" IFC array
        @a_Attributes = Array.new
        @a_Attributes << set_SweptArea
        @a_Attributes << set_Position
        @a_Attributes << set_ExtrudedDirection(loop)
        @a_Attributes << set_Depth(depth)
      end
    end
    
    class IfcArbitraryClosedProfileDef < IfcBase
      attr_accessor :record_nr, :entityType
      def initialize(ifc_exporter, bt_entity, loop)
        @ifc_exporter = ifc_exporter
        @bt_entity = bt_entity
        @loop = loop
        @entityType = "IFCARBITRARYCLOSEDPROFILEDEF"
        @ifc_exporter.add(self)
        
        # "local" IFC array
        @a_Attributes = Array.new
        @a_Attributes << ".AREA."
        @a_Attributes << "$"
        @a_Attributes << IfcPolyline.new(@ifc_exporter, @bt_entity, @loop).record_nr
      end
    end
    
    class IfcPolyline < IfcBase
      attr_accessor :record_nr, :entityType
      def initialize(ifc_exporter, bt_entity, loop, closed=true)
        @ifc_exporter = ifc_exporter
        @bt_entity = bt_entity
        @loop = loop
        @entityType = "IFCPOLYLINE"
        @ifc_exporter.add(self)
        
        # "local" IFC array
        @a_Attributes = Array.new
        pts = Array.new
        
        #t = @bt_entity.geometry.transformation.inverse
        #verts = bt_entity.source.outer_loop.vertices
        #verts = @loop.vertices
        #verts.each do |vert|
          #position = vert.position#.transform! t
        @loop.each do |position|
          ifcCartesianPoint = IfcCartesianPoint.new(@ifc_exporter, position)
          pts << ifcCartesianPoint.record_nr
        end

        #add endpoint, only complete loop for a closed curve, not an open curve
        if closed == true
          pts << pts[0]
        end
        @a_Attributes << @ifc_exporter.ifcList(pts)
      end
    end
    
    class IfcObjectPlacement < IfcBase
      def initialize(ifc_exporter, bt_entity)
        @entityType = "IFCOBJECTPLACEMENT"
        ifc_exporter.add(self)
      end
    end
    
    class IfcLocalPlacement < IfcObjectPlacement
      def initialize(ifc_exporter, transformation_parent=nil, transformation=nil)
        @ifc_exporter = ifc_exporter
        @entityType = "IFCLOCALPLACEMENT"
        @ifc_exporter.add(self)
        
        # "local" IFC array
        @a_Attributes = Array.new
        @a_Attributes << set_placement(transformation_parent)
        @a_Attributes << set_placement(transformation)
      end
      
      # this should link to the placement of the parent object
      # for simplicity returns origin
      # ERROR: Field PlacementRelTo of IfcLocalPlacement cannot contain a IfcAxis2Placement3D
      def set_placement(transformation)
        if transformation.nil?
          return "$"
        else
          return IfcAxis2Placement3D.new(@ifc_exporter, transformation).record_nr
        end
      end
    end
    
    class IfcPlacement < IfcBase
      attr_accessor :location
      def initialize(ifc_exporter, bt_entity)
        @entityType = "IFCPLACEMENT"
        ifc_exporter.add(self)
      end
    end
    
    class IfcAxis2Placement3D < IfcPlacement
      attr_accessor :axis, :refDirection
      def initialize(ifc_exporter, transformation)
        @ifc_exporter = ifc_exporter
        @entityType = "IFCAXIS2PLACEMENT3D"
        @ifc_exporter.add(self)
          
        # "local" IFC array
        @a_Attributes = Array.new
        @a_Attributes << set_Location(transformation).record_nr
        @a_Attributes << set_Axis(transformation).record_nr
        @a_Attributes << set_RefDirection(transformation).record_nr # ?????????????
      end
      def set_Location(transformation)
        @location = transformation.origin #	IfcCartesianPoint
        return IfcCartesianPoint.new(@ifc_exporter, @location)
      end  
      def set_Axis(transformation)
        vec = transformation.zaxis # IfcDirection
        return IfcDirection.new(@ifc_exporter, vec)
      end  
      def set_RefDirection(transformation)
        vec = transformation.xaxis # ??? #	IfcDirection  
        return IfcDirection.new(@ifc_exporter, vec)
      end
    end
    
    class IfcCartesianPoint < IfcBase
      attr_accessor :coordinates
      def initialize(ifc_exporter, point3d)
        @ifc_exporter = ifc_exporter
        @entityType = "IFCCARTESIANPOINT"
        ifc_exporter.add(self)
        @coordinates = point3d
        
        # "local" IFC array
        @a_Attributes = Array.new
        s_Ifc = "(" # LIST
        s_Ifc = s_Ifc + @ifc_exporter.ifcLengthMeasure(@coordinates.x) # should end with 0. : IfcLengthMeasure  # LIST
        s_Ifc = s_Ifc + ", "  # LIST
        s_Ifc = s_Ifc + @ifc_exporter.ifcLengthMeasure(@coordinates.y) # should end with 0. : IfcLengthMeasure  # LIST
        s_Ifc = s_Ifc + ", "  # LIST
        s_Ifc = s_Ifc + @ifc_exporter.ifcLengthMeasure(@coordinates.z) # should end with 0. : IfcLengthMeasure  # LIST
        s_Ifc = s_Ifc + ")"  # LIST
        @a_Attributes << s_Ifc
      end
    end
    
    class IfcDirection < IfcBase
      attr_accessor :directionRatios
      def initialize(ifc_exporter, vector)
        @ifc_exporter = ifc_exporter
        @entityType = "IFCDIRECTION"
        ifc_exporter.add(self)
        vector.normalize! # direction ratios == x,y and z value of normal vector
        @directionRatios = vector
        
        #		lat = [lat[0], latpart[0] + latpart[1], latpart[2] + latpart[3]]
        #return @ifc_exporter.ifcList(lat)
        
        # "local" IFC array
        @a_Attributes = Array.new
        #s_Ifc = "(" # LIST
        #s_Ifc = s_Ifc + @ifc_exporter.ifcLengthMeasure(@directionRatios.x)#@directionRatios.x.to_s # LIST
        #s_Ifc = s_Ifc + ", "  # LIST
        #s_Ifc = s_Ifc + @ifc_exporter.ifcLengthMeasure(@directionRatios.y)#@directionRatios.y.to_s # LIST
        #s_Ifc = s_Ifc + ", "  # LIST
        #s_Ifc = s_Ifc + @ifc_exporter.ifcLengthMeasure(@directionRatios.z)#@directionRatios.z.to_s # LIST
        #s_Ifc = s_Ifc + ")"  # LIST
        aList = [@ifc_exporter.ifcReal(@directionRatios.x), @ifc_exporter.ifcReal(@directionRatios.y), @ifc_exporter.ifcReal(@directionRatios.z)]
        @a_Attributes << @ifc_exporter.ifcList(aList)#s_Ifc
      end
    end
  end # module BimTools
end # module Brewsky
