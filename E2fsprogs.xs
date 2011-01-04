/*
 * Ray Mroz - mroz@cpan.org
 *
 * Copyright (C) 2010
 * E2fsprogs.xs
 * December 2010
 *
 */


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
typedef struct blkid_struct_tag_iterate *TagIter;
typedef struct blkid_struct_dev_iterate *DevIter;

/*********************************
 * cache.c
 *
 *********************************/

/* extern void blkid_put_cache(blkid_cache cache) */
void _blkid_put_cache(Cache cache)
{
    //TODO: sort this routine out
    #ifdef __DEBUG
    printf("\tDEBUG: _blkid_put_cache()\n");
    printf("\tDEBUG: arg(1): cache_address(struct):%p\n", cache);
    #endif

    blkid_put_cache(cache);
}

/* extern int blkid_get_cache(blkid_cache cache) */
Cache _blkid_get_cache(const char *filename)
{
    #ifdef __DEBUG
    printf("\tDEBUG: _blkid_get_cache()\n");
    printf("\tDEBUG: arg(1): filename:%s\n", filename);
    assert(filename);
    #endif
    
    Cache cache;

    if ( blkid_get_cache( &cache, filename ) )
    {
        #ifdef __DEBUG
        perror("\tDEBUG: blkid_get_cache(): Error retrieving cache object");
        #endif

        return NULL;
    }

    return cache;
}

/* extern void blkid_gc_cache(blkid_cache cache) */
void _blkid_gc_cache(Cache cache)
{
    #ifdef __DEBUG
    printf("\tDEBUG: _blkid_gc_cache()\n");
    printf("\tDEBUG: arg(1): cache_address(struct):%p\n", cache);
    assert(cache);
    #endif

    blkid_gc_cache(cache);
}

/*********************************
 * dev.c
 *
 *********************************/

/* extern const char *blkid_dev_devname(blkid_dev dev) */
const char *_blkid_dev_devname(Device device)
{
    #ifdef __DEBUG
    printf("\tDEBUG: _blkid_dev_devname()\n");
    printf("\tDEBUG: arg(1): device_address(struct):%p\n", device);
    #endif

    const char *devname = NULL;

    devname = blkid_dev_devname(device);
    if (devname == NULL)
    {
        #ifdef __DEBUG
        perror("\tDEBUG: blkid_dev_devname(): Error retrieving block device name");
        #endif

        return NULL;
    }

    return devname;
}

/* extern blkid_iterate blkid_iterate_begin(blkid_cache cache) */
DevIter _blkid_dev_iterate_begin(Cache cache)
{
    #ifdef __DEBUG
    printf("\tDEBUG: _blkid_dev_iterate_begin()\n");
    printf("\tDEBUG: arg(1): cache_address(struct):%p\n", cache);
    assert(cache);
    #endif

    DevIter iter = NULL;
    iter = blkid_dev_iterate_begin(cache);
    if (iter == NULL)
    {
        #ifdef __DEBUG
        perror("\tDEBUG: blkid_dev_iterate_begin(): error retrieving iterator");
        #endif

        return NULL;
    }

    return iter;
}

/* extern int blkid_dev_set_search(blkid_iterate iter, char *search_type, char *search_value) */
DevIter _blkid_dev_set_search(DevIter iter, char *search_type, char *search_value)
{
    #ifdef __DEBUG
    printf("\tDEBUG: _blkid_dev_set_search()\n");
    printf("\tDEBUG: arg(3): iter_address(struct):%p, srch_type:%s, srch_value:%s\n", iter, search_type, search_value);
    assert(iter);
    assert(search_type);
    assert(search_value);
    #endif

    int rc = 0;

    rc = blkid_dev_set_search(iter, search_type, search_value);
    if (rc != 0)
    {
        #ifdef __DEBUG
        perror("\tDEBUG: blkid_dev_set_search(): Error while applying search filter on iterator object");
        #endif

        return NULL;
    }

    return iter;
}

/* extern int blkid_dev_next(blkid_iterate iterate, blkid_dev *dev) */
Device _blkid_dev_next(DevIter iter)
{
    #ifdef __DEBUG
    printf("\tDEBUG: _blkid_dev_next()\n");
    printf("\tDEBUG: args(1): iter_address:%p\n", iter);
    assert(iter);
    #endif

    Device device = NULL;

    if ( blkid_dev_next(iter, &device) != 0 )
    {
        /* Return of < 0 typically means an end of list sentinal */
        #ifdef __DEBUG
        printf("\tDEBUG: blkid_dev_next()\n");
        printf("\tDEBUG: End of list (or error occurred)\n");
        #endif

        /* returns a NULL, maps as undef in Perl */
        return NULL;
    }

    /* Otherwise we return a Device object(struct * here, Perl object there).
     * Note: This device struct is malloc()'d, we must expose a DESTROY()
     * in XSUB to free() it when undef'd in Perl, else memory leak! */
    return device;
}

/* extern void blkid_iterate_end(blkid_iterate iterate) */
void _blkid_dev_iterate_end(DevIter iter)
{
    //TODO: complete
    #ifdef __DEBUG
    printf("\tDEBUG: _blkid_iterate_end()\n");
    printf("\tDEBUG: arg(1): iter_address:%p\n", iter);
    assert(iter);
    #endif

    blkid_dev_iterate_end(iter);
}

/*********************************
 * devno.c
 *
 *********************************/

/* extern char *blkid_devno_to_devname(dev_t devno) */
char *_blkid_devno_to_devname(dev_t devno)
{
    #ifdef __DEBUG
    printf("\tDEBUG: _blkid_devno_to_devname()\n");
    //printf("\tDEBUG: arg(1): devno:%d\n", devno);
    assert(devno > 0);
    #endif //__DEBUG

    /* Return devname or NULL(undef in Perl town) */
    return blkid_devno_to_devname(devno);
}

/*********************************
 * devname.c
 *
 *********************************/

/* extern int blkid_probe_all(blkid_cache cache) */
Cache _blkid_probe_all(Cache cache)
{
    #ifdef __DEBUG
    printf("\tDEBUG: _blkid_probe_all()\n");
    printf("\tDEBUG: arg(1): cache_address:%p\n", cache);
    assert(cache);
    #endif //__DEBUG

    /* Return cache struct(object) on success, NULL(undef) on fail */
    if ( blkid_probe_all(cache) != 0 )
    {
        #ifdef __DEBUG
        perror("\tDEBUG: blkid_probe_all(): Error occured while probling cache");
        #endif //__DEBUG

        return NULL;
    }
    else
    {
        return cache;
    }
}

/* extern int blkid_probe_all_new(blkid_cache cache) */
Cache _blkid_probe_all_new(Cache cache)
{
    #ifdef __DEBUG
    printf("\tDEBUG: _blkid_probe_all_new()\n");
    printf("\tDEBUG: arg(1): cache_address:%p\n", cache);
    assert(cache);
    #endif //__DEBUG

    /* Return cache struct(object) on success, NULL(undef) on fail */
    if ( blkid_probe_all_new(cache) != 0 )
    {
        #ifdef __DEBUG
        perror("\tDEBUG: blkid_probe_all_new(): Error while probing for new devices in cache");
        #endif //__DEBUG

        return NULL;
    }
    
    return cache;   
}

/* extern blkid_dev blkid_get_dev(blkid_cache cache, const char *devname, int flags) */
Device _blkid_get_dev(Cache cache, const char *devname, int flags)
{
    #ifdef __DEBUG
    printf("\tDEBUG: _blkid_get_dev()\n");
    printf("\tDEBUG: arg(3): cache_address:%p, devname:%s, flags:%d\n", cache, devname, flags);
    assert(cache);
    assert(devname);
    #endif //__DEBUG

    Device device = NULL;

    /* If we get a NULL, something is wrong, print error and return NULL(undef) */
    if ( blkid_get_dev(cache, devname, flags) == NULL )
    {
        #ifdef __DEBUG
        perror("\tDEBUG: blkid_get_dev(): Error retrieving device object");
        #endif //__DEBUG
        return NULL;
    }

    return device;
}

/*********************************
 * getsize.c
 *
 *********************************/

/* extern blkid_loff_t blkid_get_dev_size(int fd) */
blkid_loff_t _blkid_get_dev_size(int fd)
{
    #ifdef __DEBUG
    printf("\tDEBUG: _blkid_get_dev_size()\n");
    printf("\tDEBUG: arg(1): fd:%d\n", fd);
    assert(fd > 0);
    #endif //__DEBUG

    /* TODO: Determine what, if anything, is returned on error condition
     *       when a bad fd is passed in and then implement a 'perlish'
     *       return to this function.
     */
    return blkid_get_dev_size(fd);
}

/*********************************
 * probe.c
 *
 *********************************/

/* int blkid_known_fstype(const char *fstype) */
const char *_blkid_known_fstype(const char *fstype)
{
    #ifdef __DEBUG
    printf("\tDEBUG: _blkid_known_fstype()\n");
    printf("\tDEBUG: arg(1): fstype:%s\n", fstype);
    assert(fstype);
    #endif //__DEBUG

    int rc = 0;

    /* Native function returns 1 if file system is supported by lib, 0 otherwise.
     * I return the file system string if it is supported and undef if not so as
     * to have a more Perlish feel. */
    rc = blkid_known_fstype(fstype);
    if (rc == 0)
    {
        #ifdef __DEBUG
        printf("\tDEBUG: blkid_known_fstype()\n");
        printf("\tDEBUG: Unknown file system type %s\n", fstype);
        #endif //__DEBUG

        return NULL;
    }

    return fstype;
}

/* extern blkid_dev blkid_verify(blkid_cache cache, blkid_dev dev) */
Device _blkid_verify(Cache cache, Device device)
{
    #ifdef __DEBUG
    printf("\tDEBUG: _blkid_verify()\n");
    printf("\tDEBUG: arg(2): cache_address:%p, device_address:%p\n", cache, device);
    assert(cache);
    assert(device);
    #endif //__DEBUG

    Device tmp_device = NULL;

    /* Returns NULL if unable to verify device agaisnt current devname, otherwise an
     * identical copy of the device is returned to mark a pass. Return a NULL (or undef
     * to Perl on failure, a copy of the Device object on success */
    tmp_device = blkid_verify(cache, device);
    if (tmp_device == NULL)
    {
        #ifdef __DEBUG
        printf("\tDEBUG: _blkid_verify()::blkid_verify()\n");
        printf("\tDEBUG: Unable to verify block device\n");
        #endif //__DEBUG

        return NULL;
    }

    return device;
}

/*********************************
 * resolve.c
 *
 *********************************/

/* extern char *blkid_get_tag_value(blkid_cache cache, const char *tagname, const char *devname) */
char *_blkid_get_tag_value(Cache cache, const char *tagname, const char *devname)
{
    #ifdef __DEBUG
    printf("\tDEBUG: _blkid_get_tag_value()\n");
    printf("\tDEBUG: arg(3): cache_address:%p, tagname:%s, devname:%s\n", cache, tagname, devname);
    assert(cache);
    assert(tagname);
    assert(devname);
    #endif //__DEBUG

    char *tag_value = NULL;

    /* Return a NULL(undef) on fail, otherwise return the matched tag string */
    tag_value = blkid_get_tag_value(cache, tagname, devname);
    if (tag_value == NULL)
    {
        #ifdef __DEBUG
        perror("\tDEBUG: blkid_get_tag_value(): Unable to retrieve tag value from cache");
        #endif //__DEBUG

        return NULL;
    }

    return tag_value;    
}

/* extern char *blkid_get_devname(blkid_cache cache, const char *token, const char *value) */
char *_blkid_get_devname(Cache cache, const char *token, const char *value)
{
    #ifdef __DEBUG
    printf("\tDEBUG: _blkid_get_devname()\n");
    printf("\tDEBUG: arg(3): cache_address:%p, token:%s, value:%s\n", cache, token, value);
    assert(cache);
    assert(token);
    assert(value);
    #endif //__DEBUG

    char *devname = NULL;

    /* Return a NULL(undef) on fail, otherwise return the matched tag string */
    devname = blkid_get_devname(cache, token, value);
    if (devname == NULL)
    {
        #ifdef __DEBUG
        perror("\tDEBUG: blkid_get_devname(): Unable to retrieve device name");
        #endif //__DEBUG

        return NULL;
    }

    return devname;    
}

/*********************************
 * tag.c
 *
 *********************************/

/* extern blkid_iterate blkid_tag_iterate_begin(blkid_dev dev) */
TagIter _blkid_tag_iterate_begin(Device device)
{
    #ifdef __DEBUG
    printf("\tDEBUG: _blkid_tag_iterate_begin()\n");
    printf("\tDEBUG: arg(1): device_address:%p\n", device);
    assert(device);
    #endif //__DEBUG

    TagIter iter = NULL;

    iter = blkid_tag_iterate_begin(device);
    if (iter == NULL)
    {
        #ifdef __DEBUG
        perror("\tDEBUG: blkid_tag_iterate_begin(): Error retrieving iterator");
        #endif //__DEBUG

        return NULL;
    }

    return iter;
}

/* extern int blkid_tag_next(blkid_iterate iterate, const char **type, const char **value) */
HV *_blkid_tag_next(TagIter iter)
{
    #ifdef __DEBUG
    printf("\tDEBUG: _blkid_tag_next()\n");
    printf("\tDEBUG: arg(1): iter_address:%p\n", iter);
    assert(iter);
    #endif //__DEBUG

    int rc            = 0;
    const char *type  = NULL;
    const char *value = NULL;
    HV *tag_hash      = NULL;

    /* Used to check 'hv_store' return vals later */
    SV   *sv_type, *sv_value = NULL;
    
    /* If everything looks OK, use PerlAPI to build a hash type and a ptr to it,
     * otherwise send back a NULL(undef) */
    rc = blkid_tag_next(iter, &type, &value);
    if ( type && value && (rc == 0) )
    {
        tag_hash = (HV *)sv_2mortal((SV *)newHV());

        /* We check the returns here, 'sv' vars, to make sure that the hash
         * has been built properly, if not return a NULL(undef) */
        sv_type  = (SV *)hv_store(tag_hash, "type",  4, newSVpv(type,  0), 0);
        sv_value = (SV *)hv_store(tag_hash, "value", 5, newSVpv(value, 0), 0);
        if ( !sv_type || !sv_value )
        {
            #ifdef __DEBUG
            perror("hv_store(): Error constructing hash");
            #endif //__DEBUG

            return NULL;
        }

        return tag_hash;
    }
    else
    {
        return NULL;
    }   
}

/* extern void blkid_tag_iterate_end(blkid_iterate iterate) */
void _blkid_tag_iterate_end(TagIter iter)
{
    #ifdef __DEBUG
    printf("\tDEBUG: _blkid_tag_iterate_end()\n");
    printf("\tDEBUG: arg(1): iter_address:%p\n", iter);
    assert(iter);
    #endif //__DEBUG

    blkid_tag_iterate_end(iter);
}

/* extern int blkid_dev_has_tag(blkid_dev dev, const char *type, const char *value) */
Device _blkid_dev_has_tag(Device device, const char *type, const char *value)
{
    #ifdef __DEBUG
    printf("\tDEBUG: _blkid_dev_has_tag()\n");
    printf("\tDEBUG: args(3): device_address:%p, type:%s, value:%s\n", device, type, value);
    assert(device);
    assert(type);
    assert(value);
    #endif //__DEBUG

    /* If the specified tag is not present in device, return a NULL(undef), otherwise
     * return the device object */
    int rc = 0;
    rc = blkid_dev_has_tag(device, type, value);
    if (rc == 0)
    {
        #ifdef __DEBUG
        printf("\tDEBUG: Tag not present in device specified\n");
        #endif //__DEBUG

        return NULL;
    }

    return device;
}

/* extern blkid_dev blkid_find_dev_with_tag(blkid_cache cache, const char *type, const char *value) */
Device _blkid_find_dev_with_tag(Cache cache, const char *type, const char *value)
{
    #ifdef __DEBUG
    printf("\tDEBUG: _blkid_find_dev_with_tag()\n");
    printf("\tDEBUG: arg(3): cache_address:%p, type:%s, value:%s\n", cache, type, value);
    assert(cache);
    assert(type);
    assert(value);
    #endif //__DEBUG

    Device device = NULL;

    device = blkid_find_dev_with_tag(cache, type, value);
    if (device == NULL)
    {
        #ifdef __DEBUG
        perror("\tDEBUG: blkid_find_dev_with_tag(): Error finding device with specified tag data");
        #endif //__DEBUG

        return NULL;
    }

    return device;
}


/*
 *
 * TODO:: Complete last two function wrappers. These are of the more involved variety, such as
 *        blkid_tag_next() above which returns a Perl hash (HV *) via the PerlAPI for C, and my
 *        brain is fried after 12 hours of coding.
 *
 */

/* /\* extern int blkid_parse_tag_string(const char *token, char **ret_type, char **ret_val) *\/ */
/* int _blkid_parse_tag_string(const char *token, char **ret_type, char **ret_val) */
/* { */
/*     //TODO: complete */
/* } */

/*********************************
 * version.c
 *
 *********************************/

/* extern int blkid_parse_version_string(const char *ver_string) */
int _blkid_parse_version_string(const char *ver_string)
{
    #ifdef __DEBUG
    printf("\tDEBUG: _blkid_parse_version_string()\n");
    printf("\tDEBUG: arg(1): ver_string:%s\n", ver_string);
    assert(ver_string);
    #endif //__DEBUG

    return blkid_parse_version_string(ver_string);
}

/* /\* extern int blkid_get_library_version(const char **ver_string, const char **date_string) *\/ */
/* int _blkid_get_library_version(const char **ver_string, const char **date_string) */
/* { */
/*     //TODO: complete */
/* } */


MODULE = Device::Blkid::E2fsprogs    PACKAGE = Device::Blkid::E2fsprogs        PREFIX = _blkid_

PROTOTYPES: DISABLE

######################################################
### cache.c    

void _blkid_put_cache(cache)
                       Cache          cache

Cache _blkid_get_cache(filename)
                       const char *   filename 

void _blkid_gc_cache(cache)
                       Cache          cache


######################################################
### dev.c    

const char *_blkid_dev_devname(device)
                       Device         device

DevIter _blkid_dev_iterate_begin(cache)
                       Cache          cache

DevIter _blkid_dev_set_search(iter, search_type, search_value)
                       DevIter        iter
                       char *         search_type
                       char *         search_value

Device _blkid_dev_next(iter)
                       DevIter        iter

void _blkid_dev_iterate_end(iter)
                       DevIter        iter


######################################################
### devno.c

char *_blkid_devno_to_devname(devno)
                       dev_t          devno


######################################################
### devname.c

Cache _blkid_probe_all(cache)
                       Cache          cache

Cache _blkid_probe_all_new(cache)
                       Cache          cache

Device _blkid_get_dev(cache, devname, flags)
                       Cache          cache
                       const char *   devname
                       int            flags


######################################################
### getsize.c

blkid_loff_t _blkid_get_dev_size(fd)
                       int            fd


######################################################
### probe.c

const char *_blkid_known_fstype(fstype)
                       const char *   fstype

Device _blkid_verify(cache, device)
                       Cache          cache
                       Device         device


######################################################
### resolve.c

char *_blkid_get_tag_value(cache, tagname, devname)
                       Cache          cache
                       const char *   tagname
                       const char *   devname

char *_blkid_get_devname(cache, token, value)
                       Cache          cache
                       const char *   token
                       const char *   value


######################################################
### tag.c

TagIter _blkid_tag_iterate_begin(device)
                       Device         device

HV *_blkid_tag_next(iter)
                       TagIter        iter
    
void _blkid_tag_iterate_end(iter)
                       TagIter        iter

Device _blkid_dev_has_tag(device, type, value)
                       Device         device
                       const char *   type
                       const char *   value

Device _blkid_find_dev_with_tag(cache, type, value)
                       Cache          cache
                       const char *   type
                       const char *   value


    
######################################################
### version.c

int _blkid_parse_version_string(ver_string)
                       const char *   ver_string



##########################################################################################################
### Object resource cleanup
###
###
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


MODULE = Device::Blkid::E2fsprogs    PACKAGE = Device::Blkid::E2fsprogs::DevIter          PREFIX = _blkid_

void _blkid_DESTROY(iter)
                       DevIter        iter
                   CODE:
                       printf("In DevIter::DESTROY\n");
                       free(iter);


MODULE = Device::Blkid::E2fsprogs    PACKAGE = Device::Blkid::E2fsprogs::TagIter          PREFIX = _blkid_

void _blkid_DESTROY(iter)
                       TagIter        iter
                   CODE:
                       printf("In TagIter::DESTROY\n");
                       free(iter);
