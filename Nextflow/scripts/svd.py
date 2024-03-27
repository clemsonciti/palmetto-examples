import numpy as np
import matplotlib.pyplot as plt
import sys
from PIL import Image
import PIL

# import and format image to numpy
image = Image.open(sys.argv[1])
numim= np.array(list(image.getdata(band=0)),float)
numim.shape = (image.size[1], image.size[0])
numim = np.matrix(numim)

#calculate svd
u, s, v = np.linalg.svd(numim)

rankedimage = u[:,:45] @ np.diag(s[:45]) @ v[:45,:]

#write image to file
svdim = plt.imshow(rankedimage)
plt.savefig("tillman_svdpy.jpg")
