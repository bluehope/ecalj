include ../Makefile.define

TARGET=na

out1=out.lmf.$(TARGET)

all: help

help:
	@echo "Do not call this Makefile alone."

###########################################################
#----- subroutine test1.exec
define test1.exec
	#-------------------------------------------
	# Case na: illustration of low- and high-lying local orbitals
	#-------------------------------------------
	#
	# --- Test 1.  Basic check of programs lmfa,lmf ---
	#
	@cat message.test1.$(TARGET)
	$(bindir)/lmfa --no-iactiv $(TARGET) -vnk=6 -vbigbas=t -vnapval=0 > $1 2>&1
	$(LMFP)  --no-iactiv $(TARGET) -vnk=6 -vbigbas=t -vnapval=0 >> $1 2>&1
	rm rst.$(TARGET) mixm.$(TARGET)
	$(bindir)/lmfa --no-iactiv $(TARGET) -vnk=6 -vbigbas=t -vnapval=1 >> $1 2>&1
	$(LMFP)  --no-iactiv $(TARGET) -vnk=6 -vbigbas=t -vnapval=1 >> $1 2>&1
	rm mixm.$(TARGET)
	$(LMFP)  --no-iactiv $(TARGET) -vnk=6 -vbigbas=t -vnapval=2 \
		--rs=1,1,1,1,1 >> $1 2>&1
endef

###########################################################
# exec default case for $(TARGET).
$(TARGET).exec:
	$(call test1.exec,$(out1))
	$(call test1.check,$(REFDIR)/$(out1),$(out1))

# check default case for $(TARGET).
$(TARGET).check:
	$(call test1.check,$(REFDIR)/$(out1),$(out1))

# exec case1 for $(TARGET).
$(TARGET).case1.exec:
	@echo "nothing to exec for $@"

# check case1 for $(TARGET).
$(TARGET).case1.check:
	@echo "nothing to check for $@"
