module osc.addresspattern;

import osc.oscstring;

///
alias AddressPart= OscString!('/');

unittest{
    static assert(isOscString!(AddressPart));
}

///
alias  AddressPattern = AddressPart[];

///
size_t size(in AddressPattern addressPattern){
    import std.algorithm;
    import std.functional;
    auto seed = AddressPart();
    return addressPattern.fold!((a, b)=> a~b)(seed)
                         .size;
}
unittest{
    AddressPattern pattern = [AddressPart("foo"), AddressPart("bar")];
    assert(pattern.size == 12);
}
