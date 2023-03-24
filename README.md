# ft950gqrx
CAT wrapper for Yeasu FT-950 and Gqrx
This little application allows your Yaesu FT-950 to talk to Gqrx.
It's very helpful if you want to use an Panadapter on your FT-950.

The wrapper pulls the frequency from the transceiver and set the LNB_LO of Gqrx to the right frequency. So the frequency updates while you spin the VFO-Knob.

Currently, only Frequency from transceiver to Gqrx is supported. in later releases, you can set the frequency of you transceiver with Gqrx and also modes.

ft950gqrx can also be used for other transveivers. You just have to adjust the CAT-Commands.
