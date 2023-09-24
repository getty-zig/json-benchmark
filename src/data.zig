pub const Pastries = []struct {
    id: []const u8,
    type: []const u8,
    name: []const u8,
    ppu: f64,
    batters: struct {
        batter: []struct {
            id: []const u8,
            type: []const u8,
        },
    },
    topping: []struct {
        id: []const u8,
        type: []const u8,
    },
};

pub const Canada = struct {
    type: []const u8,
    features: []struct {
        type: []const u8,
        properties: struct {
            name: []const u8,
        },
        geometry: struct {
            type: []const u8,
            coordinates: [][][2]f64,
        },
    },
};
