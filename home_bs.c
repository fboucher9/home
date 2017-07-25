/* See LICENSE for license details */

/*

Module: home_bs.c

Description:

    Binary miscellaneous functions.

*/

#define _FILE_OFFSET_BITS 64
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* buffer system:
    buffer[0] = file offset
    shift last 32 bytes to first 32 bytes
    read new 1024-32 bytes
    */

struct file_object
{
    FILE*
        file_ptr;

    off_t
        file_len;

};

static
int
file_object_open(
    struct file_object * const
        file_object_ptr,
    char const * const
        file_name_ptr,
    int const
        is_write_access)
{
    int
        result;

    file_object_ptr->file_ptr =
        fopen(
            file_name_ptr,
            is_write_access ? "r+b" : "rb");

    if (file_object_ptr->file_ptr)
    {
        fseeko(
            file_object_ptr->file_ptr,
            0l,
            SEEK_END);

        file_object_ptr->file_len =
            ftello(
                file_object_ptr->file_ptr);

        fseeko(
            file_object_ptr->file_ptr,
            0l,
            SEEK_SET);

        result =
            1;
    }
    else
    {
        result =
            0;
    }

    return
        result;

}

static
void
file_object_close(
    struct file_object * const
        file_object_ptr)
{
    fclose(
        file_object_ptr->file_ptr);
}

static
void
file_object_seek(
    struct file_object * const
        file_object_ptr,
    off_t const
        file_off)
{
    fseeko(
        file_object_ptr->file_ptr,
        file_off,
        SEEK_SET);
}

static
unsigned int
file_object_read(
    struct file_object * const
        file_object_ptr,
    void * const
        read_buffer_ptr,
    unsigned int const
        read_buffer_len)
{
    unsigned int
        result;

    result =
        fread(
            read_buffer_ptr,
            1,
            read_buffer_len,
            file_object_ptr->file_ptr);

    return
        result;

}

static
unsigned int
file_object_write(
    struct file_object * const
        file_object_ptr,
    void const * const
        write_buffer_ptr,
    unsigned int const
        write_buffer_len)
{
    unsigned int
        result;

    result =
        fwrite(
            write_buffer_ptr,
            1,
            write_buffer_len,
            file_object_ptr->file_ptr);

    return
        result;

}

static
off_t
scan_file_offset(
    char const * const
        arg)
{
    unsigned long long int
        value;

    value =
        0ull;

    sscanf(
        arg,
        "%llx",
        &value);

    return
        (off_t)(
            value);

}

struct search_object
{
    struct file_object
        file_obj;

    off_t
        ulFileOffset;

    off_t
        ulSearchLength;

    unsigned int
        uiPatternLength;

    unsigned char
        aucPattern[32u];

};

static
int
parse_search_options(
    struct search_object * const
        search_object_ptr,
    int const
        argc,
    char** const
        argv)
{
    int
        result;

    signed long long int
        value;

    unsigned int
        uiPatternIterator;

    unsigned long int
        ulHexadecimalValue;

    if (argc > 4)
    {
        /* argv[1] file
            argv[2] off
            argv[3] len
            argv[4] pattern
            */

        if (
            file_object_open(
                &search_object_ptr->file_obj,
                argv[1u],
                0))
        {
            search_object_ptr->ulFileOffset = scan_file_offset(argv[2u]);
            if ((search_object_ptr->ulFileOffset < 0) || (search_object_ptr->ulFileOffset > search_object_ptr->file_obj.file_len))
            {
                search_object_ptr->ulFileOffset = search_object_ptr->file_obj.file_len;
            }

            value = 0;
            sscanf(argv[3u], "%lld", &value);
            search_object_ptr->ulSearchLength = (off_t)(value);

            /* detect if pattern or file name */
            search_object_ptr->uiPatternLength = (argc - 4);
            if (search_object_ptr->uiPatternLength < 32u)
            {
                for (uiPatternIterator = 0u; uiPatternIterator < search_object_ptr->uiPatternLength; uiPatternIterator++)
                {
                    ulHexadecimalValue = 0ul;
                    sscanf(argv[4+uiPatternIterator], "%lx", &ulHexadecimalValue);
                    search_object_ptr->aucPattern[uiPatternIterator] = (unsigned char)(ulHexadecimalValue & 0xFFul);
                }

                result =
                    1;
            }
            else
            {
                result =
                    0;
            }
        }
        else
        {
            result =
                0;
        }
    }
    else
    {
        result =
            0;
    }

    return
        result;

}

static
int
do_search(
    int argc,
    char** argv)
{
    unsigned int
        uiReadLength;

    unsigned int
        uiBufferProducerOffset;

    unsigned int
        uiBufferConsumerOffset;

    unsigned int
        uiBufferConsumerLength;

    off_t
        ulConsumerOffset;

    unsigned long int
        ulSearchIterator;

    char
        bEndOfFile;

    struct search_object
        search_obj;

    static unsigned char aucBuffer[1024u];

    if (
        parse_search_options(
            &search_obj,
            argc,
            argv))
    {
        if ((search_obj.ulSearchLength < 0) || (search_obj.ulSearchLength > (search_obj.file_obj.file_len - search_obj.ulFileOffset)))
        {
            search_obj.ulSearchLength = (search_obj.file_obj.file_len - search_obj.ulFileOffset);
        }

        file_object_seek(
            &search_obj.file_obj,
            search_obj.ulFileOffset);

        bEndOfFile = 0;
        ulConsumerOffset = search_obj.ulFileOffset;
        ulSearchIterator = 0ul;

        uiBufferProducerOffset = 0u;
        while (!bEndOfFile && (ulSearchIterator < search_obj.ulSearchLength))
        {
            uiReadLength = (unsigned int)(sizeof(aucBuffer) - uiBufferProducerOffset);
            if (ulSearchIterator + uiReadLength > search_obj.ulSearchLength)
            {
                uiReadLength = (unsigned int)(search_obj.ulSearchLength - ulSearchIterator);
            }

            if (uiReadLength == file_object_read(&search_obj.file_obj, aucBuffer + uiBufferProducerOffset, uiReadLength))
            {
                /* scan the buffer to find the pattern */
                /* total bytes in buffer = uiReadLength + uiBufferProducerOffset */
                /* scan from 0 to uiReadLength + uiBufferProducerOffset - uiPatternLength */
                uiBufferConsumerLength =
                    uiReadLength + uiBufferProducerOffset - search_obj.uiPatternLength + 1;

                for (
                    uiBufferConsumerOffset = 0u;
                    uiBufferConsumerOffset < uiBufferConsumerLength;
                    uiBufferConsumerOffset ++)
                {
                    if (
                        aucBuffer[uiBufferConsumerOffset] == search_obj.aucPattern[0])
                    {
                        if ((search_obj.uiPatternLength == 1)
                            || (0 == memcmp(
                                    aucBuffer + uiBufferConsumerOffset + 1,
                                    search_obj.aucPattern + 1,
                                    search_obj.uiPatternLength - 1)))
                        {
                            fprintf(stdout, "%llx\n", (unsigned long long int)(ulConsumerOffset + uiBufferConsumerOffset));
                            return 0;
                        }
                    }
                }
                ulConsumerOffset = ulConsumerOffset + uiBufferConsumerLength;

                /* copy end of buffer to beginning */
                if (search_obj.uiPatternLength > 1)
                {
                    memcpy(
                        aucBuffer,
                        aucBuffer + uiBufferConsumerLength,
                        search_obj.uiPatternLength - 1);

                    uiBufferProducerOffset = search_obj.uiPatternLength - 1;
                }

                ulSearchIterator = ulSearchIterator + uiReadLength;
            }
            else
            {
                bEndOfFile = 1;
            }
        }

        file_object_close(
            &search_obj.file_obj);
    }
    else
    {
        fprintf(stderr, "bs s file off len pat...\n");
    }

    return 1;
}

static
int
do_bsearch(
    int argc,
    char** argv)
{
    unsigned int
        uiReadLength;

    unsigned int
        uiBufferProducerOffset;

    unsigned int
        uiBufferConsumerOffset;

    off_t
        ulConsumerOffset;

    unsigned long int
        ulSearchIterator;

    char
        bEndOfFile;

    struct search_object
        search_obj;

    static unsigned char aucBuffer[1024u];

    if (
        parse_search_options(
            &search_obj,
            argc,
            argv))
    {
        if ((search_obj.ulSearchLength < 0) || (search_obj.ulSearchLength > search_obj.ulFileOffset))
        {
            search_obj.ulSearchLength = search_obj.ulFileOffset;
        }

        /* search from ulFileOffset to ulFileOffset-ulSearchLength */
        bEndOfFile = 0;
        ulConsumerOffset = search_obj.file_obj.file_len + 1;
        ulSearchIterator = 0ul;
        uiBufferProducerOffset = (unsigned int)(sizeof(aucBuffer));
        while (!bEndOfFile && (ulSearchIterator < search_obj.ulSearchLength))
        {
            uiReadLength = uiBufferProducerOffset;
            if (ulSearchIterator + uiReadLength > search_obj.ulSearchLength)
            {
                uiReadLength = (unsigned int)(search_obj.ulSearchLength - ulSearchIterator);
            }

            if ((sizeof(aucBuffer) - uiBufferProducerOffset + uiReadLength) >= search_obj.uiPatternLength)
            {
                file_object_seek(
                    &search_obj.file_obj,
                    search_obj.ulFileOffset - ulSearchIterator - uiReadLength);

                if (uiReadLength == file_object_read(&search_obj.file_obj, aucBuffer + uiBufferProducerOffset - uiReadLength, uiReadLength))
                {
                    /* search for last match in this buffer */
                    /* or search backwards from end of buffer */
                    /* try both methods and select quickest method */

                    for (uiBufferConsumerOffset = uiBufferProducerOffset - uiReadLength;
                        uiBufferConsumerOffset < sizeof(aucBuffer);
                        uiBufferConsumerOffset ++)
                    {
                        if (aucBuffer[uiBufferConsumerOffset] == search_obj.aucPattern[0u])
                        {
                            if ((1 == search_obj.uiPatternLength)
                                || (0 == memcmp(
                                    &aucBuffer[uiBufferConsumerOffset + 1],
                                    &search_obj.aucPattern[1u],
                                    search_obj.uiPatternLength - 1)))
                            {
                                ulConsumerOffset =
                                    (unsigned long int)(
                                        search_obj.ulFileOffset
                                        - ulSearchIterator
                                        + uiBufferConsumerOffset
                                        - uiBufferProducerOffset);
                            }
                        }
                    }

                    if (ulConsumerOffset < search_obj.file_obj.file_len)
                    {
                        fprintf(stdout, "%llx\n", (unsigned long long int)(ulConsumerOffset));
                        return 0;
                    }

                    if (search_obj.uiPatternLength > 1u)
                    {
                        memcpy(
                            aucBuffer,
                            aucBuffer + sizeof(aucBuffer) - search_obj.uiPatternLength + 1,
                            search_obj.uiPatternLength - 1);

                        uiBufferProducerOffset = (unsigned int)(sizeof(aucBuffer) - search_obj.uiPatternLength + 1);
                    }

                    ulSearchIterator += uiReadLength;
                }
                else
                {
                    fprintf(stderr, "end of file\n");
                    bEndOfFile = 1;
                }
            }
            else
            {
                bEndOfFile = 1;
            }
        }
        /* use increments of sizeof(aucBuffer) */
        /* in each block, keep last match */
        /* when changing block, copy from begin to end */

        file_object_close(
            &search_obj.file_obj);
    }
    else
    {
        fprintf(stderr, "bs s file off len pat...\n");
    }

    return 1;
}

struct diff_object
{
    struct file_object
        file_obj;

    off_t
        ulFileOffset;

    off_t
        ulSearchLength;

    struct file_object
        ref_obj;

};

static
int
parse_diff_options(
    struct diff_object * const
        diff_object_ptr,
    int const
        argc,
    char** const
        argv)
{
    int
        result;

    signed long long int
        value;

    /* argv[1] file
       argv[2] off
       argv[3] len
       argv[4] file
       */

    if (argc > 4)
    {
        if (
            file_object_open(
                &diff_object_ptr->file_obj,
                argv[1u],
                0))
        {
            diff_object_ptr->ulFileOffset = scan_file_offset(argv[2u]);
            if ((diff_object_ptr->ulFileOffset < 0) || (diff_object_ptr->ulFileOffset > diff_object_ptr->file_obj.file_len))
            {
                diff_object_ptr->ulFileOffset = diff_object_ptr->file_obj.file_len;
            }

            value = 0;
            sscanf(argv[3u], "%lld", &value);
            diff_object_ptr->ulSearchLength = (off_t)(value);

            /* diff mode */
            if (
                file_object_open(
                    &diff_object_ptr->ref_obj,
                    argv[4u],
                    0))
            {
                if (diff_object_ptr->ulFileOffset > diff_object_ptr->ref_obj.file_len)
                {
                    fprintf(stderr, "file offset out of range\n");
                    return 1;
                }

                result =
                    1;
            }
            else
            {
                result =
                    0;
            }
        }
        else
        {
            result =
                0;
        }
    }
    else
    {
        result =
            0;
    }

    return
        result;

}

static
int
do_diff(
    int argc,
    char** argv)
{
    unsigned int
        uiReadLength;

    unsigned int
        uiBufferConsumerOffset;

    unsigned int
        uiDifferenceLength;

    off_t
        ulDifferenceOffset;

    off_t
        ulConsumerOffset;

    unsigned long int
        ulSearchIterator;

    struct diff_object
        diff_obj;

    char
        bEndOfFile;

    static unsigned char aucBuffer[1024u];
    static unsigned char aucReference[1024u];

    if (
        parse_diff_options(
            &diff_obj,
            argc,
            argv))
    {
        if ((diff_obj.ulSearchLength < 0) || (diff_obj.ulSearchLength > (diff_obj.file_obj.file_len - diff_obj.ulFileOffset)))
        {
            diff_obj.ulSearchLength = (diff_obj.file_obj.file_len - diff_obj.ulFileOffset);
        }

        if (diff_obj.ulSearchLength > (diff_obj.ref_obj.file_len - diff_obj.ulFileOffset))
        {
            diff_obj.ulSearchLength = (diff_obj.ref_obj.file_len - diff_obj.ulFileOffset);
        }

        file_object_seek(
            &diff_obj.file_obj,
            diff_obj.ulFileOffset);

        file_object_seek(
            &diff_obj.ref_obj,
            diff_obj.ulFileOffset);

        bEndOfFile = 0;
        ulSearchIterator = 0ul;
        ulConsumerOffset = diff_obj.ulFileOffset;
        uiDifferenceLength = 0u;
        ulDifferenceOffset = 0ul;
        while (!bEndOfFile && (ulSearchIterator < diff_obj.ulSearchLength))
        {
            uiReadLength = (unsigned int)(sizeof(aucBuffer));
            if (ulSearchIterator + uiReadLength > diff_obj.ulSearchLength)
            {
                uiReadLength = (unsigned int)(diff_obj.ulSearchLength - ulSearchIterator);
            }

            if (uiReadLength == file_object_read(&diff_obj.file_obj, aucBuffer, uiReadLength))
            {
                if (uiReadLength == file_object_read(&diff_obj.ref_obj, aucReference, uiReadLength))
                {
                    for (
                        uiBufferConsumerOffset = 0u;
                        uiBufferConsumerOffset < uiReadLength;
                        uiBufferConsumerOffset ++)
                    {
                        if (
                            aucBuffer[uiBufferConsumerOffset] == aucReference[uiBufferConsumerOffset])
                        {
                            if (uiDifferenceLength)
                            {
                                fprintf(stdout, "%llx %u\n", (unsigned long long int)(ulDifferenceOffset), uiDifferenceLength);
                                return 0;
                            }
                        }
                        else
                        {
                            /* try to determine length of difference... */
                            if (0 == uiDifferenceLength)
                            {
                                ulDifferenceOffset = ulConsumerOffset + uiBufferConsumerOffset;
                            }
                            uiDifferenceLength ++;
                        }
                    }

                    ulConsumerOffset += uiReadLength;

                    ulSearchIterator += uiReadLength;
                }
                else
                {
                    bEndOfFile = 1;
                }
            }
            else
            {
                bEndOfFile = 1;
            }
        }

        if (uiDifferenceLength)
        {
            fprintf(stdout, "%llx %u\n", (unsigned long long int)(ulDifferenceOffset), uiDifferenceLength);
        }

        file_object_close(
            &diff_obj.ref_obj);

        file_object_close(
            &diff_obj.file_obj);
    }
    else
    {
        fprintf(stderr, "bs d file off len file\n");
    }

    return 1;
}

static
int
do_bdiff(
    int argc,
    char** argv)
{
    unsigned int
        uiReadLength;

    unsigned int
        uiBufferConsumerOffset;

    unsigned int
        uiDifferenceLength;

    off_t
        ulDifferenceOffset;

    off_t
        ulConsumerOffset;

    unsigned long int
        ulSearchIterator;

    struct diff_object
        diff_obj;

    char
        bEndOfFile;

    static unsigned char aucBuffer[1024u];
    static unsigned char aucReference[1024u];

    if (
        parse_diff_options(
            &diff_obj,
            argc,
            argv))
    {
        if ((diff_obj.ulSearchLength < 0) || (diff_obj.ulSearchLength > diff_obj.ulFileOffset))
        {
            diff_obj.ulSearchLength = diff_obj.ulFileOffset;
        }

        bEndOfFile = 0;
        ulSearchIterator = 0ul;
        ulConsumerOffset = diff_obj.ulFileOffset;
        uiDifferenceLength = 0u;
        ulDifferenceOffset = 0ul;
        while (!bEndOfFile && (ulSearchIterator < diff_obj.ulSearchLength))
        {
            uiReadLength = (unsigned int)(sizeof(aucBuffer));
            if (ulSearchIterator + uiReadLength > diff_obj.ulSearchLength)
            {
                uiReadLength = (unsigned int)(diff_obj.ulSearchLength - ulSearchIterator);
            }

            file_object_seek(
                &diff_obj.file_obj,
                ulConsumerOffset - uiReadLength);

            file_object_seek(
                &diff_obj.ref_obj,
                ulConsumerOffset - uiReadLength);

            if (uiReadLength == file_object_read(&diff_obj.file_obj, aucBuffer, uiReadLength))
            {
                if (uiReadLength == file_object_read(&diff_obj.ref_obj, aucReference, uiReadLength))
                {
                    for (
                        uiBufferConsumerOffset = 0u;
                        uiBufferConsumerOffset < uiReadLength;
                        uiBufferConsumerOffset ++)
                    {
                        if (
                            aucBuffer[uiReadLength - uiBufferConsumerOffset] == aucReference[uiReadLength - uiBufferConsumerOffset])
                        {
                            if (uiDifferenceLength)
                            {
                                fprintf(stdout, "%llx %u\n", (unsigned long long int)(ulDifferenceOffset), uiDifferenceLength);
                                return 0;
                            }
                        }
                        else
                        {
                            /* try to determine length of difference... */
                            if (0 == uiDifferenceLength)
                            {
                                ulDifferenceOffset = ulConsumerOffset - uiBufferConsumerOffset;
                            }
                            uiDifferenceLength ++;
                        }
                    }

                    ulConsumerOffset -= uiReadLength;

                    ulSearchIterator += uiReadLength;
                }
                else
                {
                    bEndOfFile = 1;
                }
            }
            else
            {
                bEndOfFile = 1;
            }
        }

        if (uiDifferenceLength)
        {
            fprintf(stdout, "%llx %u\n", (unsigned long long int)(ulDifferenceOffset), uiDifferenceLength);
        }

        file_object_close(
            &diff_obj.ref_obj);

        file_object_close(
            &diff_obj.file_obj);
    }
    else
    {
        fprintf(stderr, "bs d file off len file\n");
    }

    return 1;
}

static
int
do_read(
    int argc,
    char** argv)
{
    struct file_object
        file_obj;

    off_t
        ulFileOffset;

    unsigned int
        uiReadLength;

    unsigned int
        uiReadIterator;

    unsigned int
        uiBlockLength;

    unsigned int
        uiBufferIterator;

    unsigned int
        uiLineIterator;

    unsigned int
        uiColumnIterator;

    char
        bEndOfFile;

    static
    char
    acHexLine[1024u];

    static
    unsigned char
    aucBuffer[1024u];

    /*  argv[1] = file
        argv[2] = off
        argv[3] = len */

    if (argc > 3)
    {
        if (
            file_object_open(
                &file_obj,
                argv[1u],
                0))
        {
            ulFileOffset = scan_file_offset(argv[2u]);
            if ((ulFileOffset < 0) || (ulFileOffset > file_obj.file_len))
            {
                ulFileOffset = file_obj.file_len;
            }

            uiReadLength = 0u;
            sscanf(argv[3u], "%u", &uiReadLength);
            if ((ulFileOffset + uiReadLength) > file_obj.file_len)
            {
                uiReadLength = (unsigned int)(file_obj.file_len - ulFileOffset);
            }

            if (uiReadLength)
            {
                file_object_seek(
                    &file_obj,
                    ulFileOffset);

                bEndOfFile = 0;
                uiReadIterator = 0u;
                while (!bEndOfFile && (uiReadIterator < uiReadLength))
                {
                    uiBlockLength = (unsigned int)(sizeof(aucBuffer));
                    if (uiReadIterator + uiBlockLength > uiReadLength)
                    {
                        uiBlockLength = (unsigned int)(uiReadLength - uiReadIterator);
                    }

                    uiBlockLength = file_object_read(&file_obj, aucBuffer, uiBlockLength);
                    if (0 != uiBlockLength)
                    {
                        uiBufferIterator = 0u;
                        while (uiBufferIterator < uiBlockLength)
                        {
                            uiLineIterator = 0u;
                            for (uiColumnIterator = 0u; uiColumnIterator < 16u; uiColumnIterator++)
                            {
                                if (uiBufferIterator + uiColumnIterator < uiBlockLength)
                                {
                                    unsigned char ucHexCode;
                                    ucHexCode = aucBuffer[uiBufferIterator + uiColumnIterator];
                                    sprintf(acHexLine + uiLineIterator, " %02x", (unsigned int)(ucHexCode));
                                    uiLineIterator += 3u;
                                }
                            }
                            fprintf(stdout, "%s\n", acHexLine+1);
                            uiBufferIterator += 16u;
                        }

                        uiReadIterator = uiReadIterator + uiBlockLength;
                    }
                    else
                    {
                        bEndOfFile = 1;
                    }
                }
                fprintf(stdout, "\n");
            }

            file_object_close(
                &file_obj);
        }
        else
        {
            fprintf(stderr, "unable to open file %s\n", argv[1u]);
        }
    }
    else
    {
        fprintf(stderr, "bs r file off len\n");
    }

    return 0;
}

static
int
do_length(int argc, char** argv)
{
    struct file_object
        file_obj;

    if (argc > 1)
    {
        if (
            file_object_open(
                &file_obj,
                argv[1u],
                0))
        {
            fprintf(stdout, "%09llx\n", (unsigned long long int)(file_obj.file_len));

            file_object_close(
                &file_obj);
        }
    }
    else
    {
        fprintf(stderr, "bs l file\n");
    }

    return 0;
}

static
int
do_write(int  argc, char** argv)
{
    struct file_object
        file_obj;

    off_t
        ulFileOffset;

    int
        argi;

    unsigned int
        uiDataValue;

    unsigned int
        uiBufferLength;

    static
        unsigned char
        aucBuffer[4u];

    /*  argv[1u] = "file"
        argv[2u] = "off"
        argv[3u] = "data"
        ...
        */

    if (argc > 3)
    {
        if (
            file_object_open(
                &file_obj,
                argv[1u],
                1))
        {
            ulFileOffset = scan_file_offset(argv[2u]);
            if ((ulFileOffset < 0) || (ulFileOffset > file_obj.file_len))
            {
                ulFileOffset = file_obj.file_len;
            }

            file_object_seek(
                &file_obj,
                ulFileOffset);

            argi = 3;
            uiBufferLength = 0u;
            while (argi < argc)
            {
                uiDataValue = 0u;
                sscanf(argv[argi], "%x", &uiDataValue);

                if (uiBufferLength >= sizeof(aucBuffer))
                {
                    file_object_write(&file_obj, aucBuffer, uiBufferLength);
                    uiBufferLength = 0u;
                }

                aucBuffer[uiBufferLength] = (unsigned char)(uiDataValue & 0xFFu);
                uiBufferLength ++;

                ulFileOffset ++;
                argi++;
            }

            /* flush accumulated buffer */
            if (uiBufferLength)
            {
                file_object_write(&file_obj, aucBuffer, uiBufferLength);
                uiBufferLength = 0u;
            }

            file_object_close(
                &file_obj);
        }
        else
        {
        }
    }
    else
    {
        fprintf(stderr, "bs w file off data...\n");
    }

    return 0;
}

static
int
do_print(
    int const
        argc,
    char** const
        argv)
{
    struct file_object
        file_obj;

    off_t
        ulFileOffset;

    unsigned int
        uiReadWidth;

    unsigned int
        uiReadLength;

    unsigned int
        uiReadIterator;

    unsigned int
        uiBlockLength;

    unsigned int
        uiBufferIterator;

    unsigned int
        uiColumnIterator;

    unsigned int
        uiLineIterator;

    char
        bEndOfFile;

    static
    char
    acHexLine[1024u];

    static
    char
    acTextLine[256u];

    static
    unsigned char
    aucBuffer[1024u];

    /*  argv[1] = file
        argv[2] = off
        argv[3] = width
        argv[4] = height */

    if (argc > 4)
    {
        if (
            file_object_open(
                &file_obj,
                argv[1u],
                0))
        {
            ulFileOffset = scan_file_offset(argv[2u]);
            if ((ulFileOffset < 0) || (ulFileOffset > file_obj.file_len))
            {
                ulFileOffset = file_obj.file_len;
            }

            uiReadLength = 0u;
            sscanf(argv[3u], "%u", &uiReadLength);
            if ((ulFileOffset + uiReadLength) > file_obj.file_len)
            {
                uiReadLength = (unsigned int)(file_obj.file_len - ulFileOffset);
            }

            uiReadWidth = 0u;
            sscanf(argv[4u], "%u", &uiReadWidth);
            if (uiReadWidth == 0u)
            {
                uiReadWidth = 1u;
            }
            if (uiReadWidth > 128u)
            {
                uiReadWidth = 128u;
            }

            if (uiReadLength)
            {
                file_object_seek(
                    &file_obj,
                    ulFileOffset);

                bEndOfFile = 0;
                uiReadIterator = 0u;
                uiColumnIterator = 0u;
                uiLineIterator = 0u;
                while (!bEndOfFile && (uiReadIterator < uiReadLength))
                {
                    uiBlockLength = (unsigned int)((sizeof(aucBuffer) / uiReadWidth) * uiReadWidth);
                    if (uiReadIterator + uiBlockLength > uiReadLength)
                    {
                        uiBlockLength = (unsigned int)(uiReadLength - uiReadIterator);
                    }

                    uiBlockLength = file_object_read(&file_obj, aucBuffer, uiBlockLength);
                    if (0 != uiBlockLength)
                    {
                        uiBufferIterator = 0u;
                        while (uiBufferIterator < uiBlockLength)
                        {
                            uiLineIterator = 0u;

                            for (uiColumnIterator = 0u; uiColumnIterator < uiReadWidth; uiColumnIterator++)
                            {
                                if (uiBufferIterator + uiColumnIterator < uiBlockLength)
                                {
                                    unsigned char ucHexCode;
                                    ucHexCode = aucBuffer[uiBufferIterator + uiColumnIterator];
                                    sprintf(acHexLine + uiLineIterator, " %02x", (unsigned int)(ucHexCode));
                                    if ((ucHexCode >= 32) && (ucHexCode < 127))
                                    {
                                        acTextLine[uiColumnIterator] = (char)(ucHexCode);
                                    }
                                    else
                                    {
                                        acTextLine[uiColumnIterator] = '.';
                                    }
                                }
                                else
                                {
                                    sprintf(acHexLine + uiLineIterator, " --");
                                    acTextLine[uiColumnIterator] = '.';
                                }
                                uiLineIterator += 3u;
                            }

                            acTextLine[uiReadWidth] = '\0';

                            fprintf(stdout, "%3lx%07lx|%s |%s|\n",
                                (unsigned long int)(
                                    (ulFileOffset + uiBufferIterator) >> 28u),
                                (unsigned long int)(
                                    (ulFileOffset + uiBufferIterator) & 0x0FFFFFFFul),
                                acHexLine,
                                acTextLine);

                            uiBufferIterator += uiReadWidth;
                        }

                        ulFileOffset = ulFileOffset + uiBlockLength;
                        uiReadIterator = uiReadIterator + uiBlockLength;
                    }
                    else
                    {
                        bEndOfFile = 1;
                    }
                }
                fprintf(stdout, "\n");
            }

            file_object_close(
                &file_obj);
        }
        else
        {
            fprintf(stderr, "unable to open file %s\n", argv[1u]);
        }
    }
    else
    {
        fprintf(stderr, "bs p file off len cols\n");
    }

    return 0;
}

int main(int argc, char** argv)
{
    if (argc > 1)
    {
        if (0 == strcmp(argv[1u], "s"))
        {
            return do_search(argc-1, argv+1);
        }
        else if (0 == strcmp(argv[1u], "S"))
        {
            return do_bsearch(argc-1, argv+1);
        }
        else if (0 == strcmp(argv[1u], "d"))
        {
            return do_diff(argc-1, argv+1);
        }
        else if (0 == strcmp(argv[1u], "D"))
        {
            return do_bdiff(argc-1, argv+1);
        }
        else if (0 == strcmp(argv[1u], "r"))
        {
            return do_read(argc-1, argv+1);
        }
        else if (0 == strcmp(argv[1u], "l"))
        {
            return do_length(argc-1, argv+1);
        }
        else if (0 == strcmp(argv[1u], "w"))
        {
            return do_write(argc-1, argv+1);
        }
        else if (0 == strcmp(argv[1u], "p"))
        {
            return do_print(argc-1, argv+1);
        }
        else
        {
            printf("invalid command\n");
        }
    }
    else
    {
        printf(
            "Length:    bs l file\n"
            "Print:     bs p file off len cols\n"
            "Write:     bs w file off len data...\n"
            "Search:    bs s file off len pattern...\n"
            "Search(r): bs S file off len pattern...\n"
            "Diff:      bs d file off len file\n"
            "Diff(r):   bs D file off len file\n");
    }

    return 0;
}
