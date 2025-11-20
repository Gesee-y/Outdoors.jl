
@testset "Event Structures" begin
    # KeyboardEvent constructor
    ev = KeyboardEvent(1, "A", true, false, false, false; Mkey="A", Pkey="a")

    @test ev.id == 1
    @test ev.key == "A"
    @test ev.Mkey == "A"
    @test ev.Pkey == "a"
    @test ev.just_pressed == true
    @test ev.pressed == false
    @test ev.just_released == false
    @test ev.released == false

    # Copy constructor
    ev2 = KeyboardEvent(ev, true, true)
    @test ev2.id == ev.id
    @test ev2.key == ev.key
    @test ev2.just_pressed == true
    @test ev2.just_released == true

    # Click types paramétrés
    lc = LeftClick{1}()
    rc = RightClick{3}()
    mc = MiddleClick{1}()

    @test lc isa ClickEvent
    @test rc isa ClickEvent
    @test mc isa ClickEvent

    @test LeftDoubleClick() isa LeftClick{2}
    @test RightDoubleClick() isa RightClick{2}

    # MouseClickEvent
    m = MouseClickEvent(LeftClick{1}(), true, false, false, true)
    @test m.type isa LeftClick{1}
    @test m.just_pressed == true
    @test m.pressed == false
    @test m.just_released == false
    @test m.released == true

    # Mouse motion
    mm = MouseMotionEvent(10, 20, -1, 3)
    @test mm.x == 10
    @test mm.y == 20
    @test mm.xrel == -1
    @test mm.yrel == 3

    # Wheel
    mw = MouseWheelEvent(0, -2)
    @test mw.xwheel == 0
    @test mw.ywheel == -2
end

@testset "DeviceState" begin
    d = Outdoors.DeviceState()
    @test d.updated == false
    @test d.cnt == 0

    Outdoors._update_count(d)
    @test d.cnt == 1

    Outdoors._reset_count(d)
    @test d.cnt == 0

    d.updated = false
    Outdoors._update_count(d)
    @test d.cnt == 1
end

@testset "InputData & InputState" begin
    inp = Outdoors.InputState()

    @test inp.KBState isa Outdoors.DeviceState
    @test inp.MBState isa Outdoors.DeviceState
    @test inp.MMState isa Outdoors.DeviceState
    @test inp.MWState isa Outdoors.DeviceState

    data = inp.data
    @test data.Keyboard == Dict{String,KeyboardEvent}()
    @test data.MouseButtons == Dict{String,MouseClickEvent}()
    @test data.Axes == Dict{String,AxisEvent}()

    # Reset
    inp.KBState.cnt = 5
    reset(inp)
    @test inp.KBState.cnt == 0
    @test inp.MBState.cnt == 0
    @test inp.MMState.cnt == 0
    @test inp.MWState.cnt == 0
end

@testset "UpdateDevice Logic" begin
    inp = Outdoors.InputState()
    data = inp.data

    # Fake keyboard update function modifying state
    flag = Ref(false)
    function fake_update(data)
        flag[] = true
    end

    d = inp.KBState

    # Case 1 : count == 0 and not updated → update triggered
    d.cnt = 0
    d.updated = false
    flag[] = false

    Outdoors._UpdateDevice(inp, d, fake_update)
    @test d.updated == true
    @test flag[] == true

    # Case 2 : count != 0 → no update
    d.cnt = 1
    d.updated = false
    flag[] = false

    Outdoors._UpdateDevice(inp, d, fake_update)
    @test flag[] == false
    @test d.updated == false

    # Case 3 : count == 0 but already updated → no update
    d.cnt = 0
    d.updated = true
    flag[] = false

    Outdoors._UpdateDevice(inp, d, fake_update)
    @test flag[] == false
    @test d.updated == false  # gets reset
end
