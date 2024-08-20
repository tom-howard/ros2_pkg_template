// minimal C++ node courtesy of Robotics Backend:
https://roboticsbackend.com/write-minimal-ros2-cpp-node/

#include "rclcpp/rclcpp.hpp"
#include "ros2_pkg_template/minimal_cpp_header.hpp"

int main(int argc, char **argv)
{
    rclcpp::init(argc, argv);
    auto node = std::make_shared<rclcpp::Node>("my_node_name");
    rclcpp::spin(node);
    rclcpp::shutdown();
    return 0;
}