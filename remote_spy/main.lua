local methods = {
    get_namecall_method = true,
    get_metatable = true,
    check_caller = true
}

local ui = oh.import('remote_spy/ui')
local remote = oh.import('remote_spy/objects/remote')

local gmt = oh.methods.get_metatable(game)

local remote_spy = {}
local remote_check = {
    RemoteEvent = Instance.new("RemoteEvent").FireServer,
    RemoteFunction = Instance.new("RemoteFunction").InvokeServer,
    BindableEvent = Instance.new("BindableEvent").Fire,
    BindableFunction = Instance.new("BindableFunction").Invoke
}

local remote_hook = function(method)
    local epoch = oh.epoch 
    local h
    h = oh.methods.hook_function(method, function(obj, ...)
        if remote_check[obj.ClassName] and oh.epoch == epoch then
            local old = oh.methods.get_context()
            local object = remote.cache[obj] 
            
            oh.methods.set_context(6)

            if not object then
                object = remote.new(obj)
                ui.new_log(object)
            end
            
            if oh.methods.check_caller() or object.ignore then
                return h(obj, ...)
            end
            
            if object.block then
                return 
            end
            
            ui.update(object, ...)
            oh.methods.set_context(old)
        end

        return h(obj, ...)
    end)
end

for class_name, method in pairs(remote_check) do
    remote_hook(method)
end

remote_hook(gmt.__namecall)

remote_spy.ui = ui
remote_spy.remote = remote
return remote_spy