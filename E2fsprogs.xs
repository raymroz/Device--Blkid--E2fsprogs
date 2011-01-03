#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <blkid/blkid.h>
#include <assert.h>
#include <string.h>
#include <errno.h>

#include "ppport.h"

/*
 *
 * Typedefs - see the typemap file found at the top level of this module
 * package where all types are mapped against the proper PerlAPI types
 *
 */
typedef struct blkid_struct_cache *Cache;
typedef struct blkid_struct_dev *Device;
typedef struct blkid_struct_tag_iterate *Tag_Iterate;
typedef struct blkid_struct_dev_iterate *Dev_Iterate;

/*********************************
 * cache.c
 *
 *********************************/

/* extern void blkid_put_cache(blkid_cache cache) */
void _blkid_put_cache(Cache cache)
{
    //TODO: sort this routine out
    #ifdef __DEBUG
    printf("    DEBUG: _blkid_put_cache()\n");
    printf("    DEBUG: arg(1): cache_address(struct):%p\n", cache);
    #endif

    blkid_put_cache(cache);
}

/* extern int blkid_get_cache(blkid_cache cache) */
Cache _blkid_get_cache(const char *filename)
{
    #ifdef __DEBUG
    printf("    DEBUG: _blkid_get_cache()\n");
    printf("    DEBUG: arg(1): filename:%s\n", filename);
    assert(filename);
    #endif
    
    Cache cache;

    if ( blkid_get_cache( &cache, filename ) )
    {
        #ifdef __DEBUG
        printf("    DEBUG: _blkid_get_cache()::blkid_get_cache\n");
        printf("    DEBUG: Error retrieving cache struct: %s\n", strerror(errno));
        #endif
        croak("Error retrieving cache object on cache file %s", filename);
    }

    return cache;
}

/* extern void blkid_gc_cache(blkid_cache cache) */
void _blkid_gc_cache(Cache cache)
{
    #ifdef __DEBUG
    printf("    DEBUG: _blkid_gc_cache()\n");
    printf("    DEBUG: arg(1): cache_address(struct):%p\n", cache);
    assert(cache);
    #endif

    blkid_gc_cache(cache);
}

/*********************************
 * dev.c
 *
 *********************************/

/* extern const char *blkid_dev_devname(blkid_dev dev) */
const char *_blkid_dev_devname(Device dev)
{
    #ifdef __DEBUG
    printf("    DEBUG: _blkid_dev_devname()\n");
    printf("    DEBUG: arg(1): device_address(struct):%p\n", dev);
    #endif

    const char *device = NULL;

    device = blkid_dev_devname(dev);
    if (device == NULL)
    {
        #ifdef __DEBUG
        printf("    DEBUG: _blkid_dev_devname()::blkid_dev_devname()\n");
        printf("    DEBUG: Error occured while getting device name: %s\n", strerror(errno));
        #endif
        croak("Error occured retrieving block device name: %s\n", strerror(errno));
    }

    return device;
}

/* extern blkid_dev_iterate blkid_dev_iterate_begin(blkid_cache cache) */
Dev_Iterate _blkid_dev_iterate_begin(Cache cache)
{
    #ifdef __DEBUG
    printf("    DEBUG: _blkid_dev_iterate_begin()\n");
    printf("    DEBUG: arg(1): cache_address(struct):%p\n", cache);
    assert(cache);
    #endif

    Dev_Iterate dev_iter = NULL;
    dev_iter = blkid_dev_iterate_begin(cache);
    if (dev_iter == NULL)
    {
        #ifdef __DEBUG
        printf("    DEBUG: _blkid_dev_iterate_begin()::blkid_dev_iterate_begin()\n");
        printf("    DEBUG: Error retrieving iterator: %s\n", strerror(errno));
        #endif
        croak("Error retrieving iterator object: %s\n", strerror(errno));
    }

    return dev_iter;
}

/* extern int blkid_dev_set_search(blkid_dev_iterate iter, char *search_type, char *search_value) */
Dev_Iterate _blkid_dev_set_search(Dev_Iterate dev_iter, char *search_type, char *search_value)
{
    #ifdef __DEBUG
    printf("    DEBUG: _blkid_dev_set_search()\n");
    printf("    DEBUG: arg(3): dev_iter_address(struct):%p, srch_type:%s, srch_value:%s\n", dev_iter, search_type, search_value);
    assert(dev_iter);
    assert(search_type);
    assert(search_value);
    #endif

    int rc = 0;

    rc = blkid_dev_set_search(dev_iter, search_type, search_value);
    if (rc != 0)
    {
        #ifdef __DEBUG
        printf("    DEBUG: _blkid_dev_set_search()::blkid_dev_set_search()\n");
        printf("    DEBUG: Error occured while setting search filter on iterator: %s\n", strerror(errno));
        #endif
        croak("Error applying requested search filter on iterator: %s\n", strerror(errno));
    }

    return dev_iter;
}

/* extern int blkid_dev_next(blkid_dev_iterate iterate, blkid_dev *dev) */
Device _blkid_dev_next(Dev_Iterate dev_iter)
{
    #ifdef __DEBUG
    printf("    DEBUG: _blkid_dev_next()\n");
    printf("    DEBUG: args(1): dev_iter_address:%p\n", dev_iter);
    assert(dev_iter);
    #endif

    Device device = NULL;

    if ( blkid_dev_next(dev_iter, &device) != 0 )
    {
        /* Return of < 0 typically means an end of list sentinal */
        #ifdef __DEBUG
        printf("    DEBUG: _blkid_dev_next()::blkid_dev_next()\n");
        printf("    DEBUG: End of list or error occurred\n");
        #endif

        /* returns a NULL, maps as undef in Perl */
        return NULL;
    }

    /* Otherwise we return a Device object(struct * here, Perl object there).
     * Note: This device struct is malloc()'d, we must expose a DEMOLISH()
     * in XSUB to free() it when undef'd in Perl, else memory leak! */
    return device;
}

/* extern void blkid_dev_iterate_end(blkid_dev_iterate iterate) */
void _blkid_dev_iterate_end(Dev_Iterate dev_iter)
{
    //TODO: complete
    #ifdef __DEBUG
    printf("    DEBUG: _blkid_dev_iterate_end()\n");
    printf("    DEBUG: arg(1): dev_iter_address:%p\n", dev_iter);
    assert(dev_iter);
    #endif

    blkid_dev_iterate_end(dev_iter);
}

/*********************************
 * devno.c
 *
 *********************************/

/* /\* extern char *blkid_devno_to_devname(dev_t devno) *\/ */
/* char *_blkid_devno_to_devname(dev_t devno) */
/* { */
/*     //TODO: complete */
/* } */

/*********************************
 * devname.c
 *
 *********************************/

/* /\* extern int blkid_probe_all(blkid_cache cache) *\/ */
/* int _blkid_devno_probe_all(Cache cache) */
/* { */
/*     //TODO: complete */
/* } */

/* /\* extern int blkid_probe_all_new(blkid_cache cache) *\/ */
/* int _blkid_probe_all_new(Cache cache) */
/* { */
/*     //TODO: */
/* } */

/* /\* extern blkid_dev blkid_get_dev(blkid_cache cache, const char *devname, int flags) *\/ */
/* Device _blkid_get_dev(Cache cache, const char *devname, int flags) */
/* { */
/*     //TODO: complete */
/* } */

/*********************************
 * getsize.c
 *
 *********************************/

/* /\* extern blkid_loff_t blkid_get_dev_size(int fd) *\/ */
/* blkid_loff_t _blkid_get_dev_size(int fd) */
/* { */
/*     //TODO: complete */
/* } */

/*********************************
 * probe.c
 *
 *********************************/

/* /\* int blkid_known_fstype(const char *fstype) *\/ */
/* int _blkid_known_fstype(const char *fstype) */
/* { */
/*     //TODO: complete */
/* } */

/* /\* extern blkid_dev blkid_verify(blkid_cache cache, blkid_dev dev) *\/ */
/* Device _blkid_verify(Cache cache, Device dev) */
/* { */
/*     //TODO: complete */
/* } */

/*********************************
 * resolve.c
 *
 *********************************/

/* /\* extern char *blkid_get_tag_value(blkid_cache cache, const char *tagname, const char *devname) *\/ */
/* char *_blkid_get_tag_value(Cache cache, const char *tagname, const char *devname) */
/* { */
/*     //TODO: complete */
/* } */

/* /\* extern char *blkid_get_devname(blkid_cache cache, const char *token, const char *value) *\/ */
/* char *_blkid_get_devname(Cache cache, const char *token, const char *value) */
/* { */
/*     //TODO: complete */
/* } */

/*********************************
 * tag.c
 *
 *********************************/

/* /\* extern blkid_tag_iterate blkid_tag_iterate_begin(blkid_dev dev) *\/ */
/* Tag_Iterate _blkid_tag_iterate_beging(Device dev) */
/* { */
/*     //TODO: complete */
/* } */

/* /\* extern int blkid_tag_next(blkid_tag_iterate iterate, const char **type, const char **value) *\/ */
/* int _blkid_tag_next(Tag_Iterate iter, const char **type, const char **value) */
/* { */
/*     //TODO: complete */
/* } */

/* /\* extern void blkid_tag_iterate_end(blkid_tag_iterate iterate) *\/ */
/* void _blkid_tag_iterate_end(Tag_Iterate iter) */
/* { */
/*     //TODO: complete */
/* } */

/* /\* extern int blkid_dev_has_tag(blkid_dev dev, const char *type, const char *value) *\/ */
/* int _blkid_dev_has_tag(Device dev, const char *type, const char *value) */
/* { */
/*     //TODO: complete */
/* } */

/* /\* extern blkid_dev blkid_find_dev_with_tag(blkid_cache cache, const char *type, const char *value) *\/ */
/* Device _blkid_find_dev_with_tag(Cache cache, const char *type, const char *value) */
/* { */
/*     //TODO: complete */
/* } */

/* /\* extern int blkid_parse_tag_string(const char *token, char **ret_type, char **ret_val) *\/ */
/* int _blkid_parse_tag_string(const char *token, char **ret_type, char **ret_val) */
/* { */
/*     //TODO: complete */
/* } */

/*********************************
 * version.c
 *
 *********************************/

/* /\* extern int blkid_parse_version_string(const char *ver_string) *\/ */
/* int _blkid_parse_version_string(const char *ver_string) */
/* { */
/*     //TODO:: complete */
/* } */

/* /\* extern int blkid_get_library_version(const char **ver_string, const char **date_string) *\/ */
/* int _blkid_get_library_version(const char **ver_string, const char **date_string) */
/* { */
/*     //TODO: complete */
/* } */


MODULE = Device::Blkid::E2fsprogs    PACKAGE = Device::Blkid::E2fsprogs        PREFIX = _blkid_

PROTOTYPES: DISABLE

########################################    
### cache.c
void _blkid_put_cache(cache)
                       Cache          cache

Cache _blkid_get_cache(filename)
                       const char *   filename 

void _blkid_gc_cache(cache)
                       Cache          cache

########################################    
### dev.c
const char *_blkid_dev_devname(dev)
                       Device         dev

Dev_Iterate _blkid_dev_iterate_begin(cache)
                       Cache          cache

Dev_Iterate _blkid_dev_set_search(dev_iter, search_type, search_value)
                       Dev_Iterate    dev_iter
                       char *         search_type
                       char *         search_value

Device _blkid_dev_next(dev_iter)
                       Dev_Iterate    dev_iter

void _blkid_dev_iterate_end(dev_iter)
                       Dev_Iterate    dev_iter

########################################    
### devno.c


MODULE = Device::Blkid::E2fsprogs    PACKAGE = Device::Blkid::E2fsprogs::Cache            PREFIX = _blkid_

void _blkid_DESTROY(cache)
                       Cache          cache
                   CODE:
                       printf("In Cache::DESTROY\n");
                       free(cache);

MODULE = Device::Blkid::E2fsprogs    PACKAGE = Device::Blkid::E2fsprogs::Device           PREFIX = _blkid_

void _blkid_DESTROY(device)
                       Device         device
                   CODE:
                       printf("In Device::DESTROY\n");
                       free(device);
