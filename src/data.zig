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
