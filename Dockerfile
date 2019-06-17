FROM debian:9-slim

# update repositories
RUN apt-get update -y

# create a user
RUN adduser user --gecos "User" --disabled-password
RUN echo "user:user" | chpasswd
RUN usermod -aG sudo user

# create a ssh server
# https://docs.docker.com/engine/examples/running_ssh_service/
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN echo 'export NOTVISIBLE="in users profile"' >> /home/user/.bashrc
RUN echo "export VISIBLE=now" >> /etc/profile
EXPOSE 22

# clone qt4 git repository
WORKDIR /home/user
RUN apt-get install -y expect build-essential git
RUN git clone git://code.qt.io/qt/qt.git

# install dependencies and configure qt
RUN apt-get install -y '^libxcb.*-dev' libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev
WORKDIR qt
ENV QT_DIR /home/user/Qt4
RUN mkdir ${QT_DIR}
RUN ./configure -opensource -confirm-license -prefix ${QT_DIR} --no-javascript-jit -no-script -no-scripttools

# Following is a workaround to a compilation error with gcc6+
# https://forum.qt.io/topic/75842/can-t-compile-qt-4-8-7/15
RUN sed -i '/view()->selectionModel()->select(index, QItemSelectionModel::Columns & QItemSelectionModel::Deselect);/c\view()->selectionModel()->select(index, static_cast<QItemSelectionModel::SelectionFlags>(QItemSelectionModel::Columns & QItemSelectionModel::Deselect));' ./src/plugins/accessible/widgets/itemviews.cpp

#compile qt
RUN make -j2
RUN make install
ENV PATH="/home/user/Qt4/bin:${PATH}"
RUN echo "export PATH=$PATH" >> /home/user/.bashrc

COPY --chown=user:user ./example /home/user/example


# run ssh server
CMD ["/usr/sbin/sshd", "-D"]