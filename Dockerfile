ARG PROJECT="adore_if_carla"
ARG REQUIREMENTS_FILE="requirements.${PROJECT}.build.ubuntu20.04.system"

FROM carlasim/carla:0.9.12 AS carlasim_carla
FROM adore_if_ros_msg:latest AS adore_if_ros_msg
FROM ros:noetic-ros-core-focal AS adore_if_carla_builder


ARG PROJECT
ARG REQUIREMENTS_FILE



RUN mkdir -p /tmp/${PROJECT}
RUN mkdir -p build 
WORKDIR /tmp/${PROJECT}
RUN mkdir -p /tmp/${PROJECT}/launch
copy launchfiles/demo014_adore_if_carla_part.launch /tmp/${PROJECT}/launch
COPY --from=carlasim_carla /home/carla/CarlaUE4/Content/Carla/Maps/OpenDrive/Town10HD.xodr /tmp/${PROJECT}/launch/Town10HD.xodr
copy files/${REQUIREMENTS_FILE} /tmp/${PROJECT}


RUN apt-get update && \
    xargs apt-get install --no-install-recommends -y < ${REQUIREMENTS_FILE} && \
    rm -rf /var/lib/apt/lists/*

COPY --from=adore_if_ros_msg /tmp/adore_if_ros_msg /tmp/adore_if_ros_msg
WORKDIR /tmp/adore_if_ros_msg/build
RUN cmake --install . --prefix /tmp/${PROJECT}/build/install

copy files external/ros-bridge/carla_msgs /tmp/carla_msgs
SHELL ["/bin/bash", "-c"]
WORKDIR /tmp/carla_msgs
RUN source /opt/ros/noetic/setup.bash && \
    cmake . && \
    make && \
    cmake --install . --prefix /tmp/${PROJECT}/build/install




#RUN mkdir -p /tmp/${PROJECT}/build/devel && \
#    cd /tmp/${PROJECT}/build && ln -s devel install 


COPY ${PROJECT} /tmp/${PROJECT}
#copy files/catkin_build.sh /tmp/${PROJECT}



WORKDIR /tmp/${PROJECT}
SHELL ["/bin/bash", "-c"]
WORKDIR /tmp/${PROJECT}/build
RUN source /opt/ros/noetic/setup.bash && \
    cmake .. && \
    #make && \
    cmake --build . --config Release --target install -- -j $(nproc) && \
    cmake --install . --prefix /tmp/${PROJECT}/build/install
    #cpack -G DEB && find . -type f -name "*.deb" | xargs mv -t . || true




#FROM ros:noetic-ros-core-focal

#ARG PROJECT


#COPY --from=adore_if_carla_builder /tmp/${PROJECT}/build /tmp/${PROJECT}/build

#RUN useradd -ms /bin/bash adore_if_carla_user
#USER adore_if_carla_user



#RUN source /opt/ros/noetic/setup.bash && \
#    cmake .. -DBUILD_adore_TESTING=ON -DCMAKE_PREFIX_PATH=install -DCMAKE_INSTALL_PREFIX:PATH=install && \
#    cmake --build . --config Release --target install -- -j $(nproc) && \
#    cpack -G DEB && find . -type f -name "*.deb" | xargs mv -t . 
#RUN bash catkin_build.sh

#FROM alpine:3.14

#ARG PROJECT
#COPY --from=adore_v2x_sim_builder /tmp/${PROJECT}/build /tmp/${PROJECT}/build
