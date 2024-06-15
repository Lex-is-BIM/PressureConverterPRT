local params = Style.GetParameterValues().General
local mounting = params.MountingOptions
local rPipe=params.PipeDiameter/2
local fHeight = params.FittingHeight
local connSize = params.ConnectionSize
local rFitting = (connSize =="M") and 11.5 or 7.85
local lFitting = math.cos(math.asin(rFitting/rPipe))*rPipe+fHeight
local elPortPlac = Placement3D(Point3D(34,0,lFitting+85),Vector3D(1,0,0),Vector3D(-1,0,0))

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




