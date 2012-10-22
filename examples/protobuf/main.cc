#include <iostream>
#include <protobuf_data.pb.h>

int main(int argc, char* argv[])
{
  pb::ProtobufData data;
  data.set_name("hej");
  std::cout << data.name() << std::endl;
}
