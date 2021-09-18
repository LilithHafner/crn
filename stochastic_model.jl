using IterTools
#=using StaticArrays

struct UnitSphere{D, T}
    pos :: SVector{D, T}
    vel :: SVector{D, T}
end
UnitSphere(x,y,xv,yv) = UnitSphere(SVector{2}([x, y]), SVector{2}([xv, yv]))=#
struct DUnitSphere
    pos
    vel
end
UnitSphere(x,y,xv,yv) = UnitSphere([x, y], [xv, yv])

pos(obj::DUnitSphere) = obj.pos
vel(obj::DUnitSphere) = obj.vel
radius(obj::DUnitSphere) = one(eltype(typeof(pos(obj))))

function next(model, dt, shape)
    global world = Array{Vector{Int}}(undef, shape...)
    for i in Iterators.product(axes(world)...)
        world[i...] = []
    end
    for (i, obj) in enumerate(model)
        radius(obj)
        global bounds = [
            pos(obj) .+ radius(obj),
            pos(obj) .- radius(obj),
            pos(obj) .+ radius(obj) .+ dt .* vel(obj),
            pos(obj) .- radius(obj) .+ dt .* vel(obj)]
        push!.(world[[
            Int(floor(minimum(getindex.(bounds, d)))):Int(ceil(maximum(getindex.(bounds, d))))
            for d in axes(pos(obj),1)]...], i)
    end
    close = Set{Tuple{Int, Int}}()
    for i in Iterators.product(axes(world)...)
        for (j,a) in enumerate(world[i...])
            for b in world[i...][j+1:end]
                push!(close, (a,b))
            end
        end
    end
    close
end

next([DUnitSphere(2,2,3,4.1),DUnitSphere(4,4,-1,-1),DUnitSphere(7,7,0,-2)], 1, (10,10))
