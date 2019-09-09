QUAR_DIR = quartus
QSYS_DIR = qsys
SW_DIR = sw

#export PROJECT = chasing_led
#export PROJECT = collision_led
#export PROJECT = pwm
#export PROJECT = rot_sq
export PROJECT = heartbeat

all: build 

build: quartus/$(PROJECT).sof
	$(MAKE) -C $(SW_DIR) -e all

$(QUAR_DIR)/$(PROJECT).sof: $(QSYS_DIR)/$(PROJECT).sopcinfo
	$(MAKE) -C $(QUAR_DIR) -e all

$(QSYS_DIR)/$(PROJECT).sopcinfo: $(QSYS_DIR)/$(PROJECT).qsys
	$(MAKE) -C $(QSYS_DIR) -e all

clean:
	$(MAKE) -C $(QSYS_DIR) -e clean
	$(MAKE) -C $(QUAR_DIR) -e clean
	$(MAKE) -C $(SW_DIR) -e clean

program:
	$(MAKE) -C $(QUAR_DIR) -e program
