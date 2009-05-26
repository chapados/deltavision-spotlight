# DeltaVisionImporter

A Spotlight(TM) importer for Applied Precision DeltaVision(TM) image files.

Copyright 2006-2009 Brian Chapados <chapados@sciencegeeks.org>

## Installation

Copy DeltaVisionImporter.mdimporter to one of the following locations:

- /Library/Spotlight (system-wide install)
- ~/Library/Spotlight (user-only install)

## Extracted Metadata

The overall goal of this DeltaVisionImporter is to facilitate full-text search
of the image comment fields. This is extremely useful if you have collected
thousands of images, and you were careful place sample information into the
comment fields.

This importer extracts a limited amount of information from the image header.
Additional information is available, but is not currently extracted, since it
is not clear that it would actually be useful with having access to the raw
image data.

### Metadata Fields

#### MDItem fields

kMDItemContentType
: com.api.deltavision

kMDItemKindName
: "Applied Precision DeltaVision Image"

kMDItemPixelWidth
: Image width (pixels)

kMDItemPixelHeight
: Image height (pixels)

kMDItemBitsPerSample
: bit-depth of image pixels

kMDItemTitle
: The first "line" from the comment fields

kMDItemTextContent
: The entire contents of the comment fields

#### OME Metadata fields

This plugin provides basic "Core" metadata information as defined by openmicroscopy.org.
The definition names are in the namespace "org_openmicroscopy_OME_Pixels_<field name>".
The metadata fields are described in the [OME XML Schema specification][ome-xml].

As far as I am aware, there are no other spotlight importers that provide
standardized OME metadata. Since I didn't have any examples to use as a guide,
I tried to do things in a sensible way. If someone from OME has a better idea
about how to deal with this issue, please let me know.

[ome-xml]: http://www.openmicroscopy.org/Schemas/OME/2008-09/ome.xsd

org_openmicroscopy_OME_Pixels_SizeX
: Width of pixel data array

org_openmicroscopy_OME_Pixels_SizeY
: Height of pixel data array

org_openmicroscopy_OME_Pixels_SizeZ:
: Depth (Number of Z-planes) in pixel data array

org_openmicroscopy_OME_Pixels_SizeC
: Channels in pixel data array

org_openmicroscopy_OME_Pixels_SizeT
: Time points in pixel data array

org_openmicroscopy_OME_Pixels_NumPlanes
: Number of Planes

org_openmicroscopy_OME_Pixels_PixelType
: Pixel Type

org_openmicroscopy_OME_Pixels_DimensionOrder
: Order of 2D (XY) Image Planes in pixel data array

org_openmicroscopy_OME_Pixels_BigEndian
: True if the pixel data was written in BigEndian order.

org_openmicroscopy_OME_Pixels_PhysicalSizeX
: Pixel size in X dimension (in micrometers)

org_openmicroscopy_OME_Pixels_PhysicalSizeY
: Pixel size in Y dimension (in micrometers)

org_openmicroscopy_OME_Pixels_PhysicalSizeZ:
: Pixel size in Z dimension (in micrometers)

com_api_deltavision_ChannelWavelengths
: Wavelengths of each channel in the image stack

## Where did the DeltaVision image header information come from?

I started trying to reverse-engineer this format in 2005.  I was able to
determine some of the simple header fields (i.e. width, height, imageCount,
endian/magic number), and the location of the first comment line using a few
images and a hex editor.

Some of the offset data came from a previous version of the
 [LOCI bioformats][loci] project, when the code was still under the
LGPL license (r4047).  I used this source code to verify what I had already,
determined, as well as add a few extra features, and determine how the
DeltaVision data aligned with the OME metadata.

[loci]: http://www.loci.wisc.edu/ome/formats.html

All of the C/Objective-C code was written by me without reference to LOCI or
other implementations.

## LICENSE

This project is open source released under the LGPL license. If I hadn't had
to refer to the LOCI bio-formats projects, I would personally choose BSD, MIT
or Apache. However, I'd rather not get myself into legal trouble over this. I
can live with LGPL. I hope you can too.