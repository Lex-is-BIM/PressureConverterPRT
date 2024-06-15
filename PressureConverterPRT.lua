local params = Style.GetParameterValues().General
local mounting = params.MountingOptions
local rPipe=params.PipeDiameter/2
local fHeight = params.FittingHeight
local connSize = params.ConnectionSize
local rFitting = (connSize =="M") and 11.5 or 7.85
local lFitting = math.cos(math.asin(rFitting/rPipe))*rPipe+fHeight
local elPortPlac = Placement3D(Point3D(34,0,lFitting+85),Vector3D(1,0,0),Vector3D(-1,0,0))

function pipePlac(v)
    return Placement3D(Point3D(0,0,0),Vector3D(1*v,0,0),Vector3D(-1*v,0,0))
 end

function circ(r)
    return CreateCircle2D(Point2D(0,0),r)
end

function nut(e,m,n)
    local point = Point2D(0,e/2)
    local points = {}
    local a=n/2
    for i=0,n do
        table.insert(points, point:Clone():Rotate(Point2D(0,0),math.pi/a*i))
    end
    return Extrude(CreatePolyline2D(points),ExtrusionParameters(m))
end

function top()
    local contour = CreateRectangle2D(Point2D(0,0),0,28,28)
    FilletCorners2D(contour,3)
    return Extrude(contour,ExtrusionParameters(37)):Shift(0,0,lFitting+65)
end

local fitting = Subtract(
    Extrude(circ(rFitting),ExtrusionParameters(lFitting)),
    CreateRightCircularCylinder(rPipe,200):Shift(0,0,-100)
    :Rotate(CreateYAxis3D(),math.pi/2))

local solid = Unite({
    fitting,nut(32,12,6):Shift(0,0,lFitting),
    CreateRightCircularCylinder(13.5,38):Shift(0,0,lFitting+12),
    nut(35,10,12):Shift(0,0,lFitting+50),
    CreateRightCircularCylinder(15,5):Shift(0,0,lFitting+60),
    top(),
    Extrude(circ(10),ExtrusionParameters(0,20),elPortPlac)
})

Style.SetDetailedGeometry(ModelGeometry():AddSolid(solid))

--Symbol
function symb(r)
    local symb = GeometrySet2D()
    local contour = CreateCircle2D(Point2D(0,r),r)
    local p1=Point2D(-0.23*r,0.5*r)
    local p2=Point2D(-0.23*r,1.5*r)
    local pc1 = Point2D(0.025*r,1.3*r)
    local p3=Point2D(0.025*r,1.5*r)
    local p4=Point2D(0.225*r,1.3*r)
    local p5=Point2D(0.225*r,1.15*r)
    local pc2 = Point2D(0.025*r,1.15*r)
    local p6 = Point2D(0.025*r,0.95*r)
    local p7 = Point2D(-0.23*r,0.95*r)
    symb:AddCurve(contour)
    symb:AddMaterialColorSolidArea(FillArea(contour))
    symb:AddCurve(CreateLineSegment2D(p1,p2))
    symb:AddCurve(CreateLineSegment2D(p2,p3))
    symb:AddCurve(CreateArc2DByCenterStartEndPoints(pc1,p3,p4,true))
    symb:AddCurve(CreateLineSegment2D(p4,p5))
    symb:AddCurve(CreateArc2DByCenterStartEndPoints(pc2,p5,p6,true))
    symb:AddCurve(CreateLineSegment2D(p6,p7))
    return symb
end

local symbolicLines = GeometrySet2D()
symbolicLines:AddCurve(CreateLineSegment2D(Point2D(0,0),Point2D(0,lFitting+102)))
symbolicLines:AddCurve(CreateLineSegment2D(Point2D(0,lFitting+85),Point2D(34,lFitting+85)))

local symbolic = ModelGeometry()
symbolic:AddGeometrySet2D(symb(70):Shift(0,lFitting+102))
symbolic:AddGeometrySet2D(symbolicLines)

local symbol = ModelGeometry()
local symbolLines = GeometrySet2D():AddCurve(CreateLineSegment2D(Point2D(0,0),Point2D(0,10)))
symbol:AddGeometrySet2D(symb(5):Shift(0,10))
symbol:AddGeometrySet2D(symbolLines)

Style.SetSymbolGeometry(symbol)
Style.SetSymbolicGeometry(symbolic)

--Ports
Style.GetPort("PipeInlet"):SetPlacement(pipePlac(-1))
Style.GetPort("PipeOutlet"):SetPlacement(pipePlac(1))
Style.GetPort("ElectricPort"):SetPlacement(elPortPlac)




