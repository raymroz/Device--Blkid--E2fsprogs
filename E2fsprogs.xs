#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <blkid/blkid.h>
#include <assert.h>
#include <string.h>
#include <errno.h>

#include "ppport.h"

typedef struct blkid_struct_cache *Cache;


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

/* extern char *blkid_get_devname(blkid_cache cache, const char *token, const char *value) */

char *_blkid_evaluate_tag(const char *token, const char *value, Cache cache)
{
    #ifdef __DEBUG
    printf("    DEBUG: _blkid_evaluate_tag()\n");
    printf("    DEBUG: args(3) token:%s, value:%s, cache:%p\n", token, value, cache);
    assert(token);
    assert(value);
    #endif
    
    char *device = NULL;

    device = blkid_evaluate_tag(token, value, &cache);
    if (device == NULL)
    {
        #ifdef __DEBUG
        printf("    DEBUG: _blkid_evaluate_tag()::blkid_evaluate_tag()\n");
        printf("    DEBUG: Error occurred during tag evaluation: %s\n", strerror(errno));
        #endif
        croak("Error occurred during tag %s:%s evaluation: %s\n", token, value, strerror(errno));
    }
    
    return device;
}

MODULE = Device::Blkid::E2fsprogs    PACKAGE = Device::Blkid::E2fsprogs        PREFIX = _blkid_

PROTOTYPES: DISABLE
    
Cache _blkid_get_cache(filename)
                       const char *   filename 

    
char *_blkid_evaluate_tag(token, value, cache)
                       const char *   token
                       const char *   value
                       Cache          cache


MODULE = Device::Blkid::E2fsprogs    PACKAGE = Device::Blkid::E2fsprogs::Cache            PREFIX = _blkid_

void _blkid_DESTROY(cache)
                       Cache          cache
                   CODE:
                       printf("In Cache::DESTROY\n");
                       free(cache);
