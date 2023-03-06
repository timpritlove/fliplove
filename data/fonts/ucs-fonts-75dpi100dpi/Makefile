#TMPDIR=tmp
TMPDIR=/local/scratch/mgk25/tmp/adobe
DOWNLOADS=$(TMPDIR)/downloads

all: orig
	for dpi in 75dpi 100dpi unnec_75dpi unnec_100dpi ; do \
	  rm -rf $$dpi/ ; mkdir $$dpi/ ; \
	  cp orig/R6.4/xc/fonts/bdf/$$dpi/*.bdf $$dpi/ ; \
	  cd $$dpi/ ; \
	  chmod u+w *.bdf ; rm -f tech*.bdf term*.bdf char*.bdf symb*.bdf ; \
	  ../doit $$dpi ; cd .. ; \
	done

example: orig
	rm -rf 75dpi/ 100dpi/ unnec_75dpi/ unnec_100dpi/
	for dpi in 75dpi ; do \
	  mkdir $$dpi/ ; \
	  cp orig/R6.4/xc/fonts/bdf/$$dpi/timR12.bdf $$dpi/ ; \
	  cp orig/R6.4/xc/fonts/bdf/$$dpi/timR24.bdf $$dpi/ ; \
	  cp orig/R6.4/xc/fonts/bdf/$$dpi/helvR10.bdf $$dpi/ ; \
	  cp orig/R6.4/xc/fonts/bdf/$$dpi/courR12.bdf $$dpi/ ; \
	  cp orig/R6.4/xc/fonts/bdf/$$dpi/courBO24.bdf $$dpi/ ; \
	  cp orig/R6.4/xc/fonts/bdf/$$dpi/lutRS12.bdf $$dpi/ ; \
	  cp orig/R6.4/xc/fonts/bdf/$$dpi/luRS19.bdf $$dpi/ ; \
	  cp orig/R6.4/xc/fonts/bdf/$$dpi/UTI___14.bdf $$dpi/ ; \
	  cd $$dpi/ ; \
	  chmod u+w *.bdf ; \
	  ../doit $$dpi ; cd .. ; \
	done

pcfs:
	for i in 75dpi/*.bdf 100dpi/*.bdf \
	         unnec_75dpi/*.bdf unnec_100dpi/*.bdf ; do\
	  { bdftopcf $$i >$${i%.bdf}.pcf && \
	    gzip -9f $${i%.bdf}.pcf } || rm -f $${i%.bdf}.pcf; \
	done

ucs-fonts-75dpi100dpi.tar.gz: all
	tar chf - README Makefile make_ucs precompose doit map_fonts MAPPINGS \
	  ucs2any.pl 75dpi* 100dpi* unnec_75dpi* unnec_100dpi* | gzip -9cf >$@

distribution: ucs-fonts-75dpi100dpi.tar.gz
	mv ucs-fonts-75dpi100dpi.tar.gz $(HOME)/.www/download/

TARGET-P:
	(cd ../../unicode ; \
	uniset + 00A0-0131 + 014E-017E + CP1252.TXT + 8859-2.TXT \
	+ 8859-3.TXT + 8859-9.TXT \
	+ 8859-13.TXT + 8859-15.TXT \
	compact nr) > $@

test:
	uniset + 75dpi/timR12.bdf + 75dpi/lutRS12.bdf table | \
	glyphtest - \
	'fixed' \
	'-adobe-times-medium-r-normal--12-120-75-75-p-64-iso10646-1' \
	'-adobe-helvetica-medium-r-normal--12-120-75-75-p-67-iso10646-1' \
	'-adobe-courier-medium-r-normal--12-120-75-75-m-70-iso10646-1' \
	'-b&h-lucidatypewriter-medium-r-normal-sans-12-120-75-75-m-70-iso10646-1' \
	'-b&h-lucida-medium-r-normal-sans-14-140-75-75-p-81-iso10646-1'

# Get the various necessary source distributions

FTP=ftp://sunsite.doc.ic.ac.uk/Mirrors/ftp.x.org/pub
#FTP=ftp://ftp.x.org/pub

# needed for hidden glyphs in ncen (lost in later versions)
$(DOWNLOADS)/R3/X.V11R3.tar.gz:
	mkdir -p $(DOWNLOADS)/R3/ ;
	cd $(DOWNLOADS)/R3/ ; ncftpget \
	$(FTP)/R3/X.V11R3.tar.gz

# needed for hidden glyphs in lucida (lost in later versions)
tape1 $(DOWNLOADS)/R4/tape-1.tar.Z:
	mkdir -p $(DOWNLOADS)/R4/ ;
	cd $(DOWNLOADS)/R4/ ; ncftpget $(FTP)/R4/tape-1/tape-1.\* ; \
	cat tape-1.?? >tape-1.tar.Z ; rm tape-1.??

# primary source
$(DOWNLOADS)/R6.4/tog-2.tar.gz:
	mkdir -p $(DOWNLOADS)/R6.4/ ;
	cd $(DOWNLOADS)/R6.4/ ; ncftpget \
	$(FTP)/R6.4/tars/tog-2.tar.gz

# new source, just for comparison
$(DOWNLOADS)/R6.5.1/xorg-2.tar.gz:
	mkdir -p $(DOWNLOADS)/R6.5.1/ ;
	cd $(DOWNLOADS)/R6.5.1/ ; ncftpget \
	$(FTP)/R6.5.1/tars/xorg-2.tar.gz

# unpack the source distributions

orig: $(TMPDIR)/orig
	ln -s $(TMPDIR)/orig

$(TMPDIR)/orig: $(DOWNLOADS)/R3/X.V11R3.tar.gz $(DOWNLOADS)/R4/tape-1.tar.Z \
		$(DOWNLOADS)/R6.4/tog-2.tar.gz \
		$(DOWNLOADS)/R6.5.1/xorg-2.tar.gz
	mkdir -p $(TMPDIR)/orig/R3 ; cd $(TMPDIR)/orig/R3/ ; \
	zcat $(DOWNLOADS)/R3/X.V11R3.tar.gz | \
	tar xvf - X.V11R3/fonts/bdf/75dpi/ncenR18.bdf \
		  X.V11R3/fonts/bdf/75dpi/ncenR24.bdf
	mkdir -p $(TMPDIR)/orig/R4 ; cd $(TMPDIR)/orig/R4/ ; \
	zcat $(DOWNLOADS)/R4/tape-1.tar.Z | \
	tar xf - mit/fonts/bdf/75dpi/lut\*.bdf mit/fonts/bdf/100dpi/lut\*.bdf;\
	perl -p -i -e "s/^SWIDTH 42 0$$/SWIDTH 602 0/;" \
	  mit/fonts/bdf/75dpi/lut*.bdf mit/fonts/bdf/100dpi/lut*.bdf
	mkdir -p $(TMPDIR)/orig/R6.4 ; cd $(TMPDIR)/orig/R6.4/ ; \
	zcat $(DOWNLOADS)/R6.4/tog-2.tar.gz | \
	tar xf - xc/fonts/bdf/75dpi xc/fonts/bdf/100dpi \
	         xc/fonts/bdf/unnec_75dpi xc/fonts/bdf/unnec_100dpi ;\
	perl -p -i -e "s/^STARTCHAR multiply$$/STARTCHAR divide/ || s/^STARTCHAR divide$$/STARTCHAR multiply/;" \
	  xc/fonts/bdf/75dpi/lutRS08.bdf xc/fonts/bdf/75dpi/lutRS19.bdf \
	  xc/fonts/bdf/75dpi/lutRS24.bdf xc/fonts/bdf/100dpi/lutRS??.bdf
	mkdir -p $(TMPDIR)/orig/R6.5.1 ; cd $(TMPDIR)/orig/R6.5.1/ ; \
	zcat $(DOWNLOADS)/R6.5.1/xorg-2.tar.gz | \
	tar xf - xc/fonts/bdf/75dpi xc/fonts/bdf/100dpi \
	         xc/fonts/bdf/unnec_75dpi xc/fonts/bdf/unnec_100dpi ;\

# remove downloaded source files

download-clean:
	rm -rf $(DOWNLOADS)

# remove unpacked source files

orig-clean:
	rm -rf $(TMPDIR)/orig orig

clean:
	rm -f *~ orig ucs-fonts-75dpi100dpi.tar.gz
	rm -rf 75dpi*/ 100dpi*/ unnec_75dpi*/ unnec_100dpi*/
