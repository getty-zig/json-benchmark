const std = @import("std");

const HashMap = std.AutoHashMap;
const StringHashMap = std.StringHashMap;

const String = []const u8;

pub const Pastries = []struct {
    id: String,
    type: String,
    name: String,
    ppu: f64,
    batters: struct {
        batter: []struct {
            id: String,
            type: String,
        },
    },
    topping: []struct {
        id: String,
        type: String,
    },
};

pub const Canada = struct {
    type: String,
    features: []struct {
        type: String,
        properties: struct {
            name: String,
        },
        geometry: struct {
            type: String,
            coordinates: [][][2]f64,
        },
    },
};

pub const CITM = struct {
    areaNames: HashMap(i64, String),
    audienceSubCategoryNames: HashMap(i64, String),
    blockNames: HashMap(i64, String),
    events: HashMap(i64, Events),
    performances: []Performances,
    seatCategoryNames: HashMap(u64, String),
    subTopicNames: HashMap(u64, String),
    subjectNames: HashMap(u64, String),
    topicNames: HashMap(u64, String),
    topicSubTopics: HashMap(u64, []u64),
    venueNames: StringHashMap(String),

    const Events = struct {
        description: ?String,
        id: isize,
        logo: ?String,
        name: ?String,
        subTopicIds: []isize,
        subjectCode: ?String,
        subtitle: ?String,
        topicIds: []isize,
    };

    const Performances = struct {
        eventId: isize,
        id: isize,
        logo: ?String,
        name: ?String,
        prices: []Prices,
        seatCategories: []SeatCategories,
        seatMapImage: ?String,
        start: i64,
        venueCode: String,

        const Prices = struct {
            amount: isize,
            audienceSubCategoryId: i64,
            seatCategoryId: i64,
        };

        const SeatCategories = struct {
            areas: []Areas,
            seatCategoryId: isize,
        };

        const Areas = struct {
            areaId: isize,
            blockIds: []?isize,
        };
    };
};
