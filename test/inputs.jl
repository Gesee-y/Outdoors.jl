# Fake window type for input tests

mutable struct FakeWinData <: AbstractStyle
    pos::Tuple
end

const FakeWindow = ODWindow{FakeWinData}

Outdoors.GetMousePosition(win::FakeWindow) = win.data.pos

@testset "InputMap Basics" begin
    m = InputMap("A","B","C"; strength=0.8)

    @test m.strength == 0.8
    @test Set(["A","B","C"]) == m.keys

    AddKey(m, "D")
    @test "D" ∈ m.keys

    @test HasKey(m, "A") == true
    @test HasKey(m, "E") == false

    RemoveKey(m, "B")
    @test !("B" ∈ m.keys)

    @test GetKeys(m) == m.keys
end

@testset "@InputMap macro" begin
    @InputMap Jump("Space","W",strength=1.0)

    @test @isdefined(Jump)
    @test Jump isa InputMap
    @test "Space" ∈ Jump.keys
    @test "W" ∈ Jump.keys
    @test Jump.strength == 1.0
end

@testset "InputMap Logical Tests" begin
    win = FakeWindow(FakeWinData((0,0)))
    data = Outdoors.get_inputs_data(win)

    # Add keyboard and mouse events
    data.Keyboard["A"] = KeyboardEvent(1,"A", true, true, false, false)
    data.MouseButtons["Left"] = MouseClickEvent(LeftClick{1}(), true, true, false, false)

    m = InputMap("A","Left")

    @test IsKeyPressed(win, m) == true
    @test IsKeyJustPressed(win, m) == true

    # Simulate release
    data.Keyboard["A"] = KeyboardEvent(1,"A", false, false, false, true)
    data.MouseButtons["Left"] = MouseClickEvent(LeftClick{1}(), false, false, false, true)

    @test IsKeyPressed(win, m) == false
    @test IsKeyReleased(win, m) == true
    @test IsKeyJustReleased(win, m) == true
end

@testset "Rect2D & Point-In-Rect" begin
    r = Outdoors.Rect2D(10, 20, 100, 50)

    @test Outdoors._point_in_rect(r, 10, 20) == true
    @test Outdoors._point_in_rect(r, 50, 40) == true
    @test Outdoors._point_in_rect(r, 9, 20) == false
    @test Outdoors._point_in_rect(r, 10, 71) == false
end

@testset "InputZone Basics" begin
    z = InputZone((0,0),(100,100), 5)

    @test z.rect.x == 0
    @test z.rect.y == 0
    @test z.rect.w == 100
    @test z.rect.h == 100
    @test z.priority == 5
    @test z.focus == false
end

@testset "AttachZone & Focus" begin
    win = FakeWindow(FakeWinData((0,0)))
    z1 = InputZone((0,0),(50,50), 1)
    z2 = InputZone((50,0),(50,50), 2)

    AttachZoneToWindow(win, z1)
    AttachZoneToWindow(win, z2)

    @test win.zones[z1.id] === z1
    @test win.zones[z2.id] === z2

    EnableFocus(z1)
    @test z1.focus == true

    DisableFocus(z1)
    @test z1.focus == false

    SetZoneFocusTo(win, z2)
    @test z2.focus == true
    @test z1.focus == false

    RemoveAllZoneFocus(win)
    @test !z1.focus
    @test !z2.focus
end

@testset "Zone Mouse Position" begin
    win = FakeWindow(FakeWinData((0,0)))
    zone = InputZone((10,20),(50,50), 1)
    AttachZoneToWindow(win, zone)

    # No focus → always nothing
    @test GetMousePosition(win, zone) === nothing

    EnableFocus(zone)

    # Mouse inside zone
    win.data.pos = (30,40)
    localpos = GetMousePosition(win, zone)
    @test localpos == (20,20)

    # Mouse outside zone
    win.data.pos = (500,500)
    @test GetMousePosition(win, zone) === nothing
end
