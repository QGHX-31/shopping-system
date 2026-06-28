export interface ParsedAddress {
  name?: string
  phone?: string
  province?: string
  city?: string
  district?: string
  detail?: string
}

const PROVINCE_MAP: Record<string, string> = {
  '北京市': '北京市', '北京': '北京市',
  '上海市': '上海市', '上海': '上海市',
  '天津市': '天津市', '天津': '天津市',
  '重庆市': '重庆市', '重庆': '重庆市',
  '河北省': '河北省', '河北': '河北省',
  '山西省': '山西省', '山西': '山西省',
  '内蒙古': '内蒙古自治区', '内蒙古自治区': '内蒙古自治区',
  '辽宁省': '辽宁省', '辽宁': '辽宁省',
  '吉林省': '吉林省', '吉林': '吉林省',
  '黑龙江省': '黑龙江省', '黑龙江': '黑龙江省',
  '江苏省': '江苏省', '江苏': '江苏省',
  '浙江省': '浙江省', '浙江': '浙江省',
  '安徽省': '安徽省', '安徽': '安徽省',
  '福建省': '福建省', '福建': '福建省',
  '江西省': '江西省', '江西': '江西省',
  '山东省': '山东省', '山东': '山东省',
  '河南省': '河南省', '河南': '河南省',
  '湖北省': '湖北省', '湖北': '湖北省',
  '湖南省': '湖南省', '湖南': '湖南省',
  '广东省': '广东省', '广东': '广东省',
  '广西': '广西壮族自治区', '广西壮族自治区': '广西壮族自治区',
  '海南省': '海南省', '海南': '海南省',
  '四川省': '四川省', '四川': '四川省',
  '贵州省': '贵州省', '贵州': '贵州省',
  '云南省': '云南省', '云南': '云南省',
  '西藏': '西藏自治区', '西藏自治区': '西藏自治区',
  '陕西省': '陕西省', '陕西': '陕西省',
  '甘肃省': '甘肃省', '甘肃': '甘肃省',
  '青海省': '青海省', '青海': '青海省',
  '宁夏': '宁夏回族自治区', '宁夏回族自治区': '宁夏回族自治区',
  '新疆': '新疆维吾尔自治区', '新疆维吾尔自治区': '新疆维吾尔自治区',
  '台湾': '台湾省', '台湾省': '台湾省',
  '香港': '香港特别行政区', '香港特别行政区': '香港特别行政区',
  '澳门': '澳门特别行政区', '澳门特别行政区': '澳门特别行政区'
}

const MUNICIPALITIES = ['北京市', '上海市', '天津市', '重庆市']

const LABEL_NAMES = ['收件人', '姓名', '联系人', '收货人']
const LABEL_PHONES = ['联系电话', '手机号', '电话', '手机']
const LABEL_PROVINCES = ['省份', '省']
const LABEL_CITIES = ['城市', '市']
const LABEL_DISTRICTS = ['区/县', '区县', '区', '县']
const LABEL_DETAILS = ['详细地址', '地址', '详细']

function parseByLabel(text: string): ParsedAddress | null {
  const result: ParsedAddress = {}
  let found = false

  const allLabels = [
    { labels: LABEL_NAMES, field: 'name' as const },
    { labels: LABEL_PHONES, field: 'phone' as const },
    { labels: LABEL_PROVINCES, field: 'province' as const },
    { labels: LABEL_CITIES, field: 'city' as const },
    { labels: LABEL_DISTRICTS, field: 'district' as const },
    { labels: LABEL_DETAILS, field: 'detail' as const },
  ]

  interface LabelHit {
    start: number
    end: number
    field: keyof ParsedAddress
  }

  const hits: LabelHit[] = []

  for (const { labels, field } of allLabels) {
    for (const label of labels) {
      const escapedLabel = label.replace(/\//g, '\\/')
      const regex = new RegExp(escapedLabel + '[:：]', 'g')
      let match: RegExpExecArray | null
      while ((match = regex.exec(text)) !== null) {
        hits.push({
          start: match.index,
          end: match.index + match[0].length,
          field
        })
      }
    }
  }

  if (hits.length === 0) return null

  hits.sort((a, b) => a.start - b.start)

  for (let i = 0; i < hits.length; i++) {
    const hit = hits[i]
    const valueStart = hit.end
    const valueEnd = i < hits.length - 1 ? hits[i + 1].start : text.length
    let value = text.slice(valueStart, valueEnd).trim()

    value = value.replace(/^[\s，,；;]+/, '').replace(/[\s，,；;]+$/, '').trim()

    if (!value) continue

    if (hit.field === 'name') {
      result.name = value
      found = true
    } else if (hit.field === 'phone') {
      const phoneMatch = value.match(/1[3-9]\d{9}/)
      if (phoneMatch) {
        result.phone = phoneMatch[0]
        found = true
      }
    } else if (hit.field === 'province') {
      let prov = value
      let matched = false
      for (const [alias, standard] of Object.entries(PROVINCE_MAP)) {
        if (prov === alias || prov === standard || prov + '省' === standard) {
          result.province = standard
          matched = true
          found = true
          break
        }
      }
      if (!matched) {
        result.province = prov
        found = true
      }
    } else if (hit.field === 'city') {
      let city = value
      if (!city.endsWith('市') && city.length > 1) {
        city += '市'
      }
      result.city = city
      found = true
    } else if (hit.field === 'district') {
      result.district = value
      found = true
    } else if (hit.field === 'detail') {
      result.detail = value
      found = true
    }
  }

  return found ? result : null
}

function parseByPattern(text: string): ParsedAddress {
  const result: ParsedAddress = {}
  const original = text.trim()
  let remaining = original

  const phoneMatch = remaining.match(/\b1[3-9]\d{9}\b/)
  if (phoneMatch) {
    result.phone = phoneMatch[0]
    remaining = remaining.replace(phoneMatch[0], ' ').trim()
  }

  let foundProvince: string | undefined
  let provinceEndInRemaining = -1

  for (const [alias, standard] of Object.entries(PROVINCE_MAP)) {
    const idx = remaining.indexOf(alias)
    if (idx !== -1) {
      foundProvince = standard
      provinceEndInRemaining = idx + alias.length
      break
    }
  }

  if (foundProvince) {
    result.province = foundProvince
  }

  let foundCity: string | undefined
  let cityEndInRemaining = -1

  if (foundProvince && MUNICIPALITIES.includes(foundProvince)) {
    foundCity = foundProvince
    cityEndInRemaining = provinceEndInRemaining
  }

  if (!foundCity && foundProvince) {
    const afterProvince = remaining.slice(provinceEndInRemaining)
    const cityMatch = afterProvince.match(/([\u4e00-\u9fa5]{2,4}市)/)
    if (cityMatch) {
      foundCity = cityMatch[1]
      cityEndInRemaining = provinceEndInRemaining + (cityMatch.index || 0) + foundCity.length
    }
  } else if (!foundCity) {
    const cityMatch = remaining.match(/([\u4e00-\u9fa5]{2,4}市)/)
    if (cityMatch) {
      foundCity = cityMatch[1]
      cityEndInRemaining = (cityMatch.index || 0) + foundCity.length
    }
  }

  if (foundCity) {
    result.city = foundCity
  }

  let foundDistrict: string | undefined
  let districtEndInRemaining = -1

  let searchStart = cityEndInRemaining !== -1 ? cityEndInRemaining : (provinceEndInRemaining !== -1 ? provinceEndInRemaining : 0)
  const afterCity = remaining.slice(searchStart)

  const districtPatterns = [
    /([\u4e00-\u9fa5]{2,4}区)/,
    /([\u4e00-\u9fa5]{2,4}县)/,
    /([\u4e00-\u9fa5]{2,6}自治县)/,
    /([\u4e00-\u9fa5]{2,4}镇)/
  ]

  for (const pat of districtPatterns) {
    const m = afterCity.match(pat)
    if (m) {
      foundDistrict = m[1]
      districtEndInRemaining = searchStart + (m.index || 0) + foundDistrict.length
      break
    }
  }

  if (foundDistrict) {
    result.district = foundDistrict
  }

  if (districtEndInRemaining !== -1) {
    let detailPart = remaining.slice(districtEndInRemaining).trim()
    detailPart = detailPart
      .replace(/^\s*[,，、]\s*/, '')
      .replace(/\b1[3-9]\d{9}\b/g, '')
      .replace(/^[\u4e00-\u9fa5]{1,4}(?:先生|女士|小姐|老师)\s+/, '')
      .replace(/\s+[\u4e00-\u9fa5]{1,4}(?:先生|女士|小姐|老师)$/, '')
      .replace(/\s+/g, ' ')
      .trim()

    if (detailPart && detailPart.length > 0) {
      result.detail = detailPart
    }
  } else if (cityEndInRemaining !== -1) {
    let detailPart = remaining.slice(cityEndInRemaining).trim()
    detailPart = detailPart
      .replace(/^\s*[,，、]\s*/, '')
      .replace(/\b1[3-9]\d{9}\b/g, '')
      .replace(/^[\u4e00-\u9fa5]{1,4}(?:先生|女士|小姐|老师)\s+/, '')
      .replace(/\s+/g, ' ')
      .trim()

    if (detailPart && detailPart.length > 0) {
      result.detail = detailPart
    }
  }

  const namePatterns = [
    /^\s*([\u4e00-\u9fa5]{1,4})(?:先生|女士|小姐)?\s*[,，]/,
    /^\s*([\u4e00-\u9fa5]{1,4})(?:先生|女士|小姐)?\s+(?:1[3-9]|电话|手机)/,
    /1[3-9]\d{9}\s+([\u4e00-\u9fa5]{1,4})(?:先生|女士|小姐)?\s*[,，]/,
    /\s([\u4e00-\u9fa5]{1,3})(?:先生|女士|小姐)\s/,
    /([\u4e00-\u9fa5]{1,3})(?:先生|女士|小姐)$/,
    /^\s*([\u4e00-\u9fa5]{2,4})\s*$/
  ]

  for (const pat of namePatterns) {
    const m = original.match(pat)
    if (m) {
      const candidate = m[1]
      if (candidate.length >= 1 && !/^(省|市|区|县|自治区|特别行政区|先生|女士|小姐|老师|街道|镇|乡)$/.test(candidate)) {
        result.name = candidate
        break
      }
    }
  }

  return result
}

export function parseAddress(text: string): ParsedAddress {
  if (!text || !text.trim()) return {}

  const labelResult = parseByLabel(text)
  if (labelResult) {
    return labelResult
  }

  return parseByPattern(text)
}

export function lookupRegion(
  province: string | undefined,
  city: string | undefined,
  district: string | undefined
): { province?: string; city?: string; district?: string } {
  return {
    province: province,
    city: city,
    district: district
  }
}