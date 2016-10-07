static import osc;

void main() {
    auto client = new osc.Client(8000);
    auto message = osc.Message();
    
    message.addressPattern = "/foo";
    message.addValue(1000);
    message.addValue(-1);
    message.addValue("hello");
    message.addValue(1.234f);
    message.addValue(5.678f);
    
    client.push(message);
}
