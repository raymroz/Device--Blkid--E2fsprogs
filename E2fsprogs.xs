#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <blkid/blkid.h>
#include <assert.h>
#include <string.h>
#include <errno.h>

#include "ppport.h"

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
    printf("    DEBUG: arg(1): Cache struct address: %p\n", cache);
    #endif

    blkid_put_cache(cache);
}

/* extern int blkid_get_cache(blkid_cache cache) */
Cache _blkid_get_cache(const char *filename)
{
    #ifdef __DEBUG
    printf("    DEBUG: _blkid_get_cache()\n");
    printf("    DEBUG: arg(1): %s\n", filename);
    assert(filename);
    #endif
    
    Cache cache;

    if ( blkid_get_cache( &cache, filename ) )
    {
        #ifdef __DEBUG
        printf("    DEBUG: _blkid_get_cache()::blkid_get_cache\n");
        printf("    DEBUG: Unable to get cache struct from libblkid: %s\n", strerror(errno));
        #endif
        croak("Error retrieving blkid_cache struct on cache file %s", filename);
    }

    return cache;
}

/* extern void blkid_gc_cache(blkid_cache cache) */
void _blkid_gc_cache(Cache cache)
{
    #ifdef __DEBUG
    printf("    DEBUG: _blkid_gc_cache()\n");
    printf("    DEBUG: arg(1): Cache struct address: %p\n", cache);
    assert(cache);
    #endif

    blkd_gc_cache(cache);
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
    printf("    DEBUG: arg(1): Device struct address: %p\n", dev);
    #endif

    const char *device = NULL;

    device = blkid_dev_devname(dev);
    if (device == NULL)
    {
        #ifdef __DEBUG
        printf("    DEBUG: _blkid_dev_devname()::blkid_dev_devname()\n");
        printf("    DEBUG: Error occured while getting device name: %s\n", strerror(errno));
        #endif
        croak("Error occured while getting device name: %s\n", strerror(errno));
    }

    return device;
}

/* extern blkid_dev_iterate blkid_dev_iterate_begin(blkid_cache cache) */
Dev_Iterate _blkid_dev_iterate_begin(Cache cache)
{
    //TODO: complete
}

/* extern int blkid_dev_set_search(blkid_dev_iterate iter, char *search_type, char *search_value) */
int _blkid_dev_set_search(Dev_Iterate iter, char *search_type, char *search_value)
{
    //TODO: complete
}

/* extern int blkid_dev_next(blkid_dev_iterate iterate, blkid_dev *dev) */
int _blkid_dev_next(Dev_Iterate iter, Device *dev)
{
    //TODO: complete
}

/* extern void blkid_dev_iterate_end(blkid_dev_iterate iterate) */
void _blkid_dev_iterate_end(Dev_Iterate iter)
{
    //TODO: complete
}

/* extern char *blkid_devno_to_devname(dev_t devno) */
char *_blkid_devno_to_devname(dev_t devno)
{
    //TODO: complete
}

/* extern char *blkid_get_devname(blkid_cache cache, const char *token, const char *value) */
/* char *_blkid_evaluate_tag(const char *token, const char *value, Cache cache) */
/* { */
/*     #ifdef __DEBUG */
/*     printf("    DEBUG: _blkid_evaluate_tag()\n"); */
/*     printf("    DEBUG: Args(3) token:%s, value:%s, cache address:%p\n", token, value, cache); */
/*     assert(token); */
/*     assert(value); */
/*     #endif */
    
/*     char *device = NULL; */

/*     device = blkid_evaluate_tag(token, value, &cache); */
/*     if (device == NULL) */
/*     { */
/*         #ifdef __DEBUG */
/*         printf("    DEBUG: _blkid_evaluate_tag()::blkid_evaluate_tag()\n"); */
/*         printf("    DEBUG: Error occurred during tag evaluation: %s\n", strerror(errno)); */
/*         #endif */
/*         croak("Error occurred during tag %s:%s evaluation: %s\n", token, value, strerror(errno)); */
/*     } */
    
/*     return device; */
/* } */

MODULE = Device::Blkid::E2fsprogs    PACKAGE = Device::Blkid::E2fsprogs        PREFIX = _blkid_

PROTOTYPES: DISABLE

### cache.c
void _blkid_put_cache(cache)
                       Cache          cache

Cache _blkid_get_cache(filename)
                       const char *   filename 

### dev.c
const char *_blkid_dev_devname(dev)
                       Device         dev

### tag.c
###char *_blkid_evaluate_tag(token, value, cache)
###                       const char *   token
###                       const char *   value
###                       Cache          cache


MODULE = Device::Blkid::E2fsprogs    PACKAGE = Device::Blkid::E2fsprogs::Cache            PREFIX = _blkid_

void _blkid_DESTROY(cache)
                       Cache          cache
                   CODE:
                       printf("In Cache::DESTROY\n");
                       free(cache);
