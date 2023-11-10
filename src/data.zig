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

pub const StringUnicode = struct {
    Arabic: String,
    @"Arabic Presentation Forms-A": String,
    @"Arabic Presentation Forms-B": String,
    Armenian: String,
    Arrows: String,
    Bengali: String,
    Bopomofo: String,
    @"Box Drawing": String,
    @"CJK Compatibility": String,
    @"CJK Compatibility Forms": String,
    @"CJK Compatibility Ideographs": String,
    @"CJK Symbols and Punctuation": String,
    @"CJK Unified Ideographs": String,
    @"CJK Unified Ideographs ExtensionA": String,
    @"CJK Unified Ideographs ExtensionB": String,
    Cherokee: String,
    @"Currency Symbols": String,
    Cyrillic: String,
    @"Cyrillic Supplementary": String,
    Devanagari: String,
    @"Enclosed Alphanumerics": String,
    @"Enclosed CJK Letters and Months": String,
    Ethiopic: String,
    @"Geometric Shapes": String,
    Georgian: String,
    @"Greek and Coptic": String,
    Gujarati: String,
    Gurmukhi: String,
    @"Hangul Compatibility Jamo": String,
    @"Hangul Jamo": String,
    @"Hangul Syllables": String,
    Hebrew: String,
    Hiragana: String,
    @"IPA Extentions": String,
    @"Kangxi Radicals": String,
    Katakana: String,
    Khmer: String,
    @"Khmer Symbols": String,
    Latin: String,
    @"Latin Extended Additional": String,
    @"Latin-1 Supplement": String,
    @"Latin-Extended A": String,
    @"Latin-Extended B": String,
    @"Letterlike Symbols": String,
    Malayalam: String,
    @"Mathematical Alphanumeric Symbols": String,
    @"Mathematical Operators": String,
    @"Miscellaneous Symbols": String,
    Mongolian: String,
    @"Number Forms": String,
    Oriya: String,
    @"Phonetic Extensions": String,
    @"Supplemental Arrows-B": String,
    Syriac: String,
    Tamil: String,
    Thaana: String,
    Thai: String,
    @"Unified Canadian Aboriginal Syllabics": String,
    @"Yi Radicals": String,
    @"Yi Syllables": String,
};
