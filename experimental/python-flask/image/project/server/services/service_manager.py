_services = {}

def get(name):
    return _services[name]

def set(name, service):
    _services[name] = service
    return service

def getNames():
    return list(_services.keys())

def getAll():
    return _services