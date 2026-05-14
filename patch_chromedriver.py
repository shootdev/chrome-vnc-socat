import io
import re
import time
# docker cp /mnt/d/zjz/TaxServices/dockerfiles/patch_chromedriver.py 2edc:/home/seluser

# executable_path = '/opt/selenium/chromedriver-115.0.5790.102'
executable_path = '/bin/chromedriver'
# executable_path = r'c:/Users/yw07/Downloads/chromedriver-115.0.5790.102.exe'
print("patching driver executable %s" % executable_path)
start = time.perf_counter()

with io.open(executable_path, "r+b") as fh:
    content = fh.read()
    # match_injected_codeblock = re.search(rb"{window.*;}", content)
    match_injected_codeblock = re.search(rb"\{window\.cdc.*?;\}", content)
    if match_injected_codeblock:
        target_bytes = match_injected_codeblock[0]
        new_target_bytes = (
            b'{console.log("undetected chromedriver")}'.ljust(
                len(target_bytes), b" "
            )
        )
        new_content = content.replace(target_bytes, new_target_bytes)
        if new_content == content:
            print("something went wrong patching the driver binary. could not find injection code block")
        else:
            print('replace successfully !')
        fh.seek(0)
        fh.write(new_content)
    else:
        print('found no replace block')
print("patching took us {:.2f} seconds".format(time.perf_counter() - start))
