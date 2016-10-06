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
    return addressPattern.map!(p => AddressPart.Prefix~p.content)
                         .reduce!"a~b"
                         .addNullSuffix
                         .length;
}
unittest{
    AddressPattern pattern = [AddressPart("foo"), AddressPart("bar")];
    assert(pattern.size == 12);
}
